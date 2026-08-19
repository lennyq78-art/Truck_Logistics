# Free Cloud Deployment Guide - Render.com

Deploy your **FastAPI Backend + Live Web Dashboard** to [Render.com](https://render.com) for **100% FREE 24/7 Cloud Hosting** with automatic HTTPS SSL security!

Once deployed, your API will be live on the real internet (e.g., `https://truck-logistics-api.onrender.com`), allowing driver mobile phones across Sri Lanka to connect over **4G/5G Mobile Data** from anywhere!

---

## 🚀 Step-by-Step 1-Click Free Deployment

### Step 1: Push Project to GitHub

1. Create a repository on [GitHub.com](https://github.com/new) named `Truck_Logistics`.
2. Open PowerShell in `c:\Users\User\Downloads\Project_NEO\Truck_Logistics` and run:

```powershell
git init
git add .
git commit -m "Initial FastAPI Truck Logistics Backend and Apps"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/Truck_Logistics.git
git push -u origin main
```

---

### Step 2: Deploy to Render (100% Free)

1. Go to **[https://render.com](https://render.com)** and sign in with your GitHub account.
2. Click the **New +** button at the top right and select **Web Service**.
3. Select your `Truck_Logistics` repository from the list.
4. Render will automatically detect the [Dockerfile](file:///c:/Users/User/Downloads/Project_NEO/Truck_Logistics/Dockerfile).
5. Choose the **Free Plan** ($0 / month).
6. Click **Create Web Service**.

Render will build your Docker container and give you your live HTTPS production URL within 2 minutes:  
👉 **`https://truck-logistics-backend.onrender.com`**

---

### Step 3: Update Driver App & Owner App Base URL

Once your cloud backend is live on Render:

1. Open `driver_app/lib/config/api_config.dart` and set:
   ```dart
   class ApiConfig {
     static const String baseUrl = 'https://truck-logistics-backend.onrender.com';
   }
   ```
2. Open `owner_app/lib/config/api_config.dart` and set:
   ```dart
   class ApiConfig {
     static const String baseUrl = 'https://truck-logistics-backend.onrender.com';
   }
   ```

Now your **Redmi Note 9 Pro** and all driver phones across Sri Lanka on 4G/5G mobile data can use the app 24/7!
