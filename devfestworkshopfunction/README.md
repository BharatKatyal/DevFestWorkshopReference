# DevFestWorkshopReference

Backup Workshop: https://codelabs.developers.google.com/codelabs/how-to-cloud-run-gemini-function-calling#0


1. Create a new Google Project

2. Activate Cloud Shell and Open Code IDE - View 


3. Create a Serverless Function

```

#!/bin/bash

# Create main.py with the sample function
cat << EOF > main.py
def hello_world(request):
    return 'Hello, DevFest Workshop!'
EOF

# Create an empty requirements.txt
echo -e "Flask==2.0.1\nWerkzeug==2.0.1" > requirements.txt


# Set your project ID
PROJECT_ID=$(gcloud config get-value project)

# Enable necessary APIs
gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com

# Deploy the function
gcloud functions deploy devfest-function-final \
  --runtime python39 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point hello_world \
  --region us-central1

# Get the URL of the deployed function
gcloud functions describe devfest-function-final --region us-central1 --format='value(httpsTrigger.url)'

```

4. Create a HTML, update function url and push Bucket and Push


index.html
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevFest Workshop</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        .container {
            text-align: center;
            background-color: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #4285F4;
        }
        #result {
            margin-top: 1rem;
            font-size: 1.2rem;
        }
        button {
            background-color: #4285F4;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 1rem;
            cursor: pointer;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        button:hover {
            background-color: #3367D6;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>DevFest Workshop</h1>
        <button onclick="fetchData()">Fetch Data</button>
        <div id="result"></div>
    </div>

    <script>
        function fetchData() {
            const resultDiv = document.getElementById('result');
            resultDiv.textContent = 'Loading...';

            // Replace 'YOUR_FUNCTION_URL' with the actual URL of your deployed function
            fetch('YOUR_FUNCTION_URL')
                .then(response => response.text())
                .then(data => {
                    resultDiv.textContent = data;
                })
                .catch(error => {
                    resultDiv.textContent = 'Error: ' + error.message;
                });
        }
    </script>
</body>
</html>
```

```
BUCKET_NAME="mydevfest2024bucket"
# Set the project
gcloud config set project $PROJECT_ID

# Create a new bucket
gsutil mb -p $PROJECT_ID -c standard -l us-central1 -b on gs://$BUCKET_NAME

# Enable website configuration on the bucket
<!-- gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME -->

# Make the bucket publicly readable
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# Upload index.html and 404.html files
gsutil cp index.html gs://$BUCKET_NAME
<!-- gsutil cp 404.html gs://$BUCKET_NAME -->

# Set the correct Content-Type for HTML files
gsutil setmeta -h "Content-Type:text/html" gs://$BUCKET_NAME/*.html

# Display the website URL
echo "Your website is now available at: https://storage.googleapis.com/$BUCKET_NAME/index.html"
```


Clean up 
```
#!/bin/bash

# Set your project ID
PROJECT_ID=$(gcloud config get-value project)

# Set the bucket name
BUCKET_NAME="mydevfest2024bucket"

# Delete the Cloud Function
echo "Deleting Cloud Function..."
gcloud functions delete devfest-function --region us-central1 --quiet

# Delete the Cloud Storage bucket
echo "Deleting Cloud Storage bucket..."
gsutil rm -r gs://$BUCKET_NAME

# Disable the APIs
echo "Disabling APIs..."
gcloud services disable cloudfunctions.googleapis.com cloudbuild.googleapis.com

echo "Cleanup completed successfully!"