---
title: 'Demystifying SSH: the Invisible Thread That Connects Devops Systems'
author: Abhishek
type: post
date: 2025-06-05T11:46:18+05:30
url: "/demystifying-ssh-the-invisible-thread-that-connects-devops-systems/"
toc: true
draft: false
categories: [ "system design" ]
tags: [ "ssh" ]
---

It was 2 AM when our production system experienced an outage. Panic flooded the Slack channel. The logs were not
flowing, monitoring tools were blinking red, and our Jenkins pipelines were stuck mid-deployment. One team member calmly
opened their terminal and said, "Let me SSH into the GCP instance and see what’s going on." Within minutes, they had
diagnosed a failed process, restarted the service, and brought the system back online.

That one-liner – “Let me SSH into the instance” – was magic to most, but routine for experienced DevOps engineers. This
blog is a deep dive into that magic – SSH (Secure Shell) – a tool so fundamental, yet often misunderstood.

## Problem

In the world of modern development and DevOps, we interact with remote machines, version control systems, and CI/CD
tools regularly. Without secure, encrypted communication, everything becomes vulnerable:

* How do we securely access a remote server?
* How do tools like Jenkins, GitHub, or deployment scripts interact with cloud instances?
* How do we avoid typing passwords every time?

Without SSH, we'd rely on insecure protocols or expose systems to password-based attacks. That's a risk no production
system can afford.

## Solution

**SSH (Secure Shell)** provides a cryptographically secure way to access and manage remote machines over an unsecured
network. It uses:

* **Public-private key pairs** to authenticate users
* **Encrypted tunnels** to transfer data
* **Port forwarding** for secure redirection

SSH is not just for logging into a server; it is the backbone of secure automation and remote collaboration.

## Multiple Example in Detailed Fashion with Explanation

### 1. Putty or OpenSSH from Local to GCP VM

GCP offers SSH access to VM instances using your local machine.

**Steps:**

* Generate SSH key using `ssh-keygen`
* Add public key to VM instance metadata
* Use:

  ```bash
  ssh -i ~/.ssh/my-key username@instance-ip
  ```
* Or use PuTTY with `.ppk` key on Windows

**Use Case:** Emergency debugging, manual health checks, log analysis

### 2. Jenkins Shell to SSH into GCP Instance

Automate deployment or configuration tasks.

**Approach:**

* Add SSH private key in Jenkins credentials
* Use `ssh` command in Jenkins shell build step:

  ```bash
  ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa user@ip "sudo systemctl restart app"
  ```

**Use Case:** Automated deploys, restarts, backups

### 3. GitHub SSH Authentication

Avoid HTTPS password prompts, especially for push/pull from private repos.

**Steps:**

* Generate SSH key
* Add public key in GitHub > Settings > SSH keys
* Clone using:

  ```bash
  git@github.com:username/repo.git
  ```

**Use Case:** Secure Git operations from local or CI/CD

### 4. SSH Tunneling (Port Forwarding)

Access internal services securely without VPN.

```bash
ssh -L 8080:localhost:80 user@remote-ip
```

Now open `http://localhost:8080` to access remote web server

**Use Case:** Database access, internal dashboards

### 5. SSH Agent Forwarding

Use your local SSH identity on a remote machine to connect to another remote system.

```bash
ssh -A user@jumphost
```

**Use Case:** Multi-hop secure access across environments

### 6. Using SSH in CI/CD Pipelines

Tools like GitHub Actions, GitLab CI, CircleCI use SSH keys to:

* Deploy artifacts to remote
* Pull code from private repos
* SSH into deployment targets

**Use Case:** Full DevOps automation

## Best Practices

* Use key-based authentication, not passwords
* Set up SSH key passphrase and use `ssh-agent`
* Rotate keys periodically
* Use limited-permission users for automation
* Disable root login via SSH
* Monitor SSH access logs

## Anti-Patterns

* Committing private SSH keys to repo (security breach)
* Using the same key across environments (increased blast radius)
* Leaving SSH ports (22) open to all IPs (brute force risk)
* Not disabling password-based login

## Recommended Book

* **"SSH Mastery" by Michael W. Lucas** – Deep dive into using and securing SSH effectively.
* **"The Practice of System and Network Administration" by Thomas Limoncelli** – Practical insights including SSH usage.

## Final Thoughts

SSH is the hidden workhorse of the DevOps world – quietly powering secure communication, remote access, and automation.
From casual debugging to critical deployments, it forms the foundation of trust between tools and systems.

Once you start embracing SSH, you’ll wonder how anything in the distributed world works without it.

## Summary

* SSH enables encrypted, authenticated access to remote systems
* Used in GCP instances, CI/CD tools, GitHub, and more
* Power tool for developers, DevOps engineers, and sysadmins
* Follow best practices to maintain security

## Good Quote

> "Security is not a product, but a process. SSH is one of the most trustworthy processes we have." – Bruce Schneier (
> adapted)

That's it for today, will meet in next episode.

Happy coding :grinning:
