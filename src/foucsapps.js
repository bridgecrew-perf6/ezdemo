const apps =
[
  {
    "title": "ML 101",
    "description": "Machine Learning starting point",
    "depends": ["kubeflow"],
    "deploy":[
      {
        "name": "nbsecret",
        "yaml": 'nbsecret.yml'
      },
      {
        "name": "notebook",
        "yaml": 'notebook.yml'
      },
      {
        "name": "trainingcluster",
        "yaml": 'training.yml'
      }
    ]
  },
  {
    "title": "Jupyter Notebook",
    "description": "Just a Jupyter Notebook with pytorch, ...",
    "depends": [],
    "deploy":[
      {
        "name": "nbsecret",
        "yaml": 'nbsecret.yml'
      },
      {
        "name": "notebook",
        "yaml": 'notebook.yml'
      }
    ]
  },
  {
    "title": "Hello World",
    "description": "Welcome to Kubernetes",
    "depends": [],
    "deploy":[
      {
        "name": "helloworld",
        "yaml": 'helloworld.yml'
      }
    ]
  }
]

export default apps;