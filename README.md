# ocaml-microservice-cropping-picture

A microservice with database and simple API to crop picture written in OCaml.

## Database 

PostgreSQL is used. The default table is `cropping.picture` (where `cropping` is the specific schema for this service). The schema of this table is:
```
id                             bigserial   primary key,
initial_path                   text        NOT NULL,
cropped_path                   text        NOT NULL,
additional_information         jsonb       NOT NULL,
additional_information_version bigserial   NOT NULL
```

The initial image path is saved in the database with the path to the cropped image.
Additional information like the cropping coordinates, the initial and cropped
width and height are saved in JSON to be able to add easily new information.
For this purpose, a field with the version of the additional information structure is saved.

See `cropping.sql` for the SQL file.

### Basic additional information and JSON structure.

A basic JSON structure to send to the service is:
```JSON
{
  "blob": "data:image/png;base64...",
  "width": 42,
  "height": 42,
  "crop": {
    "top" : 1,
    "bottom" : 1,
    "left": 1,
    "right": 1
  }
}
```

For example, if you want to crop [this Google logo](https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTPo3ZCdrR8Fhcgjqhjo6IwTf8dt8eUKIowD9WruYRNCYs9lHa-V5Uw8yo) (size = 90x90) from the bottom-left corner in (15, 15) to top-right corder (30, 30), you send the following JSON:
```JSON
{
  "blob": "data:image/jpeg;base64,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",
  "width": 90,
  "height": 90,
  "crop": {
    "top": 30,
    "bottom": 15,
    "left": 15,
    "right": 30
  }
}
```

You can try this image with:
```
make test-google-image
```

## Run.

To create a local database for testing, you can use the Makefile.
```
make db-init
make db-create
make db-schema
```
It will create a new database with files in a local directory and create the table.
Other related database target are available: take a look to the Makefile for more information.

