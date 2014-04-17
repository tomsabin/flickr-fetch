require 'flickraw'
require 'mongo'

DEFAULT_PHOTOSET_ID = '72157638729659183'
FlickRaw.shared_secret = 'your-shared-secret'
FlickRaw.api_key = 'your-api-key'

module MongoDB
  include Mongo

  def self.insert(doc)
    mongo_client = MongoClient.new('localhost', 27017)
    coll = mongo_client.db('flickr_dump').collection('photoset')
    coll.drop
    doc.collect { |photo| coll.insert(photo) }
    mongo_client.close
  end
end

module Flickr
  def self.fetch_photoset(photoset_id = nil)
    photoset_id = DEFAULT_PHOTOSET_ID if photoset_id.empty?
    puts "...beginning fetch"
    begin
      response = flickr.photosets.getPhotos({ :photoset_id => photoset_id,
                                              :extras => 'url_z, url_o',
                                              :page => 1, :per_page => 500 })

      photos = response.photo.inject([]) do |result, element|
        result << { 'title' => element['title'],
                    'url_z' => element['url_z'],
                    'url_o' => element['url_o'],
                    'id' => element['id']}
        result
      end

      MongoDB.insert photos.map { |photo_hash| Flickr::Photo.new(photo_hash).to_json }
      puts "Fetch complete, found #{photos.size} photos from photoset: #{photoset_id}"
    rescue FlickRaw::FailedResponse
      puts "Fetch failed"
    end
  end

  class Photo
    def initialize(photo_hash)
      @title = photo_hash['title'] ? photo_hash['title'] : "Untitled"
      @thumbnail_image_url = photo_hash['url_z']
      @original_image_url = photo_hash['url_o']
      @photo_id = photo_hash['id']
    end

    def to_json
      {
        title: @title,
        thumbnail_image_url: @thumbnail_image_url,
        original_image_url: @original_image_url,
        id: @photo_id,
        permalink: permalink
      }
    end

    def permalink
      "http://www.flickr.com/photos/tom-sabin/#{@photo_id}/"
    end
  end
end

puts 'Please enter the photoset ID to fetch (leave blank for default):'
Flickr.fetch_photoset(gets.chomp)
