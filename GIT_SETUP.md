# Git & GitHub Setup Guide

This guide explains how to add the **Truck Logistics System** codebase to Git and push it to GitHub.

---

## 🛠️ Step 1: Install Git (If not already installed)

Download and install Git for Windows:  
👉 **[https://git-scm.com/download/win](https://git-scm.com/download/win)**  
*(Or install **[GitHub Desktop](https://desktop.github.com)** if you prefer a visual click-and-drag app!)*

---

## 💻 Step 2: Push Project to GitHub via Terminal

1. Create a new empty repository on GitHub named `Truck_Logistics` at **[https://github.com/new](https://github.com/new)**.
2. Open PowerShell/CMD in your project folder `c:\Users\User\Downloads\Project_NEO\Truck_Logistics`.
3. Run the following commands:

```powershell
# 1. Initialize local Git repository
git init

# 2. Stage all project files (.gitignore is already set up to exclude temp files)
git add .

# 3. Create initial commit
git commit -m "Initial Truck Logistics Backend, Dashboard, and Flutter Apps"

# 4. Set main branch name
git branch -M main

# 5. Connect to your GitHub repository (Replace YOUR_USERNAME with your GitHub account)
git remote add origin https://github.com/YOUR_USERNAME/Truck_Logistics.git

# 6. Push all code to GitHub!
git push -u origin main
```

---

## 🖱️ Step 3: Visual Option (GitHub Desktop)

If you use **GitHub Desktop**:
1. Open **GitHub Desktop** -> Click **File** -> **Add Local Repository**.
2. Select folder: `c:\Users\User\Downloads\Project_NEO\Truck_Logistics`.
3. Click **Create Repository**.
4. Click **Publish Repository** at the top to push it to your GitHub account!
