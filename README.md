flickr-fetch
============

Fetches a Flickr photoset and dumps to a database

## Dependencies

### [FlickrRaw](https://github.com/hanklords/flickraw)

Library to easily access Flickr's API

Install with `gem install flickraw`

Expected reponse from `flickr.photosets.getPhotos`:

```
[
  { "id"=>"11113751194",
    "secret"=>"9b31c3b5d6",
    "server"=>"3749",
    "farm"=>4,
    "title"=>"DSC_1465",
    "isprimary"=>"1",
    "url_z"=>"http://farm4.staticflickr.com/3749/11113751194_9b31c3b5d6_z.jpg",
    "height_z"=>"427",
    "width_z"=>"640",
    "url_o"=>"http://farm4.staticflickr.com/3749/11113751194_13a5b6a677_o.jpg",
    "height_o"=>"854",
    "width_o"=>"1280"
  },
  { ... }
]
```


### [Mongo Ruby Driver](https://github.com/mongodb/mongo-ruby-driver)

Current choice of database is MongoDB.

Install with `gem install mongo`

If you haven't already got MongoDB installed, install with Homebrew: `brew install mongo`. Then run the database, with a specified path as follows: `mongod --dbpath=<your-path>`.
