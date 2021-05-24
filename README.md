# Retrieve rules of origin from a Word document

## Implementation steps

- Create and activate a virtual environment, e.g.

  `python3 -m venv venv/`
  `source venv/bin/activate`

- Install necessary Python modules 

  - autopep8==1.5.7
  - lxml==4.6.3
  - marshmallow==3.11.1
  - pycodestyle==2.7.0
  - python-docx==0.8.10
  - python-dotenv==0.17.1
  - toml==0.10.2

  via `pip3 install -r requirements.txt`

## Usage

### To create a JSON file from an original Word document:
`python3 create.py <filename> <agreement>`

e.g. 

`python3 create.py roo_uk_eu eu`