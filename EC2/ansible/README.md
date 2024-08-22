# Installing Kubernetes on Ubuntu 24.04 EC2 Instance

( per https://www.linuxtechi.com/install-kubernetes-on-ubuntu-24-04/ )

This Ansible playbook installs and configures a Kubernetes cluster on an Ubuntu 24.04 EC2 instance.


## Prerequisites

- Ansible installed on your local machine.
- AWS EC2 instances running Ubuntu 24.04.
- SSH access to the EC2 instances.

## Configuration

- **vars.yml**: Defines the Kubernetes version and private IPs.
- **inventory.ini**: Lists EC2 instances with public IPs.
 
## Playbook Details

- **Common Role**: Installs Docker and Kubernetes packages, disables swap.
- **Master Role**: Initializes the Kubernetes master node and installs the Flannel CNI plugin.
- **Worker Role**: Joins the worker nodes to the Kubernetes cluster.

Configuration of each node includes the following:

- **Update and upgrade apt packages**: Ensures the system is up-to-date.
- **Install Docker**: Installs Docker, required for Kubernetes.
- **Add Kubernetes apt key and repository**: Adds the necessary apt key and repository for Kubernetes.
- **Install Kubernetes packages**: Installs `kubelet`, `kubeadm`, and `kubectl`.
- **Hold Kubernetes packages**: Prevents the packages from being automatically updated.
- **Disable swap**: Disables swap, which is required for Kubernetes.
- **Initialize Kubernetes cluster**: Initializes the Kubernetes cluster.
- **Create .kube directory and copy kubeconfig**: Sets up the kubeconfig for the `ubuntu` user.
- **Install Flannel CNI**: Installs the Flannel CNI plugin for networking.

## Notes

- Ensure that your EC2 instances have sufficient resources (CPU, RAM) to run Kubernetes.
- The playbook assumes the `ubuntu` user. Modify the playbook if you are using a different user.

Run the playbook:
```sh
ansible-playbook -i inventory.ini playbook.yml
```

## Directory Structure

To manage both the master and worker nodes, it’s generally more efficient to use a single playbook
with different roles or tasks for each type of node. This way, you can maintain a cleaner and more
organized structure. Here’s how you can set up the Ansible directory and playbook to accommodate
both master and worker nodes, using your `inventory.ini` file.

```plaintext
mkdir -p ../ansible/roles/{common,master,worker}/tasks
touch ../ansible/roles/{common,master,worker}/tasks/main.yml
tree ../ansible

../ansible
├── README.md
├── inventory.ini
├── playbook.yml
├── roles
│   ├── common
│   │   └── tasks
│   │       └── main.yml
│   ├── master
│   │   └── tasks
│   │       └── main.yml
│   └── worker
│       └── tasks
│           └── main.yml
└── vars.yml
```

## Running the Playbook

Run the playbook with:

```sh
ansible-playbook -i inventory.ini playbook.yml
```

## Troubleshooting and Debugging

### Running Specific Roles Using Tags

You can run specific roles or tasks by using tags. Tags allow you to target particular sections of your playbook without executing everything.

1. **Add Tags to Your Playbook**:
    Modify your `playbook.yml` to include tags:

    ```yaml
    ---
    - name: Setup Kubernetes Cluster
      hosts: all
      become: yes
      vars_files:
        - vars.yml
      roles:
        - role: common
          tags: common

    - name: Setup Kubernetes Master
      hosts: master
      become: yes
      vars_files:
        - vars.yml
      roles:
        - role: master
          tags: master

    - name: Setup Kubernetes Worker
      hosts: worker
      become: yes
      vars_files:
        - vars.yml
      roles:
        - role: worker
          tags: worker
    ```

2. **Run a Specific Role with Tags**:
    To run only the `worker` role, use the following command:

    ```sh
    ansible-playbook -i inventory.ini playbook.yml --tags worker
    ```

### Running the Worker Role Alone

If you want to run the `worker` role alone without using tags, you can use the `--limit` option:

```sh
ansible-playbook -i inventory.ini playbook.yml --limit worker
```

This will execute the playbook but only apply the tasks associated with the `worker` nodes.

### Debugging with a Temporary Playbook

If you encounter issues and want to isolate the `worker` role for debugging, you can create a temporary playbook that only includes the `worker` role:

1. **Create a Temporary Playbook**:

    ```yaml
    # worker_playbook.yml
    ---
    - name: Setup Kubernetes Worker
      hosts: worker
      become: yes
      vars_files:
        - vars.yml
      roles:
        - worker
    ```

2. **Run the Temporary Playbook**:

    ```sh
    ansible-playbook -i inventory.ini worker_playbook.yml
    ```

This approach allows you to focus on the `worker` role and debug any issues without affecting the rest of the setup.

### Additional Debugging Options

If you need more detailed output to troubleshoot issues:

- Use `-v`, `-vv`, `-vvv`, or `-vvvv` for increasing levels of verbosity:

    ```sh
    ansible-playbook -i inventory.ini worker_playbook.yml -vvv
    ```

This command will provide detailed output to help you understand what is happening during the playbook execution.
