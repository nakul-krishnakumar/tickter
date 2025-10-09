
# How to Run the App Locally???
The application is divided into two main parts: the server (backend) and the client (frontend). You must run both simultaneously for the app to function correctly.

### 1. Clone the Repository
First, clone the project to your local machine using Git.

git clone [https://github.com/nakul-krishnakumar/tickter.git](https://github.com/nakul-krishnakumar/tickter.git)

cd tickter

### 2. Backend Setup (server folder)
The backend is a Node.js/Express server that handles content moderation, database interactions, and other business logic.

Step 1: Navigate to the Server Directory

cd server

Step 2: Create and Configure the .env File

The server requires a .env file to store your secret keys and credentials. Create a new file named .env in the server directory and add the following variables:

SUPABASE_URL=<YOUR_SUPABASE_PROJECT_URL>

SUPABASE_SERVICE_KEY=<YOUR_SUPABASE_SERVICE_ROLE_KEY>

AZURE_ENDPOINT=<YOUR_AZURE_CONTENT_MODERATOR_ENDPOINT>

AZURE_KEY=<YOUR_AZURE_CONTENT_MODERATOR_API_KEY>

Note: The SUPABASE_SERVICE_KEY is a secret key that bypasses RLS and should only be used on a trusted server.

Step 3: Install Dependencies
Run the following command to install all the necessary Node.js packages.

npm install

Step 4: Start the Server

Run the start script to launch the local server. By default, it runs on port 8080 or 8081.

npm start

You should see a message like Server listening at http://localhost:8080. Keep this terminal window open.

### 3. Frontend Setup (client folder)
The frontend is a Flutter application that runs on an emulator or a physical device.

Step 1: Navigate to the Client Directory
Open a new terminal window and navigate to the client directory.

cd client

Step 2: Create and Configure the .env File

The Flutter app also needs a .env file for its public Supabase keys. Create a new file named .env in the client directory and add the following:

SUPABASE_URL=<YOUR_SUPABASE_PROJECT_URL>

SUPABASE_ANON_KEY=<YOUR_SUPABASE_PUBLIC_ANON_KEY>

Step 3: Install Dependencies
Run the following command to get all the required Flutter packages.

flutter pub get

Step 4: Configure the Backend Connection
Your Flutter app needs to know the IP address of your locally running server.

Find your computer's local IP address (e.g., 192.168.1.10).

Open the file lib/screens/create_post.dart.

Find the _createPost function and update the Uri.parse line with your IP address and the server's port.

// For an Android Emulator, use 10.0.2.2 to connect to your computer's localhost.
final uri = Uri.parse('[http://10.0.2.2:8080/api/v1/posts/upload](http://10.0.2.2:8080/api/v1/posts/upload)');

// For a physical device on the same Wi-Fi, use your computer's IP.
// final uri = Uri.parse('[http://192.168.1.10:8080/api/v1/posts/upload](http://192.168.1.10:8080/api/v1/posts/upload)');

Step 5: Run the App
Connect a device or start an emulator and run the app.

flutter run

Your Tickter application should now be running locally, with the Flutter client communicating with your local Node.js server.
