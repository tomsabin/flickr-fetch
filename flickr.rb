require 'flickraw'
require 'mongo'
require 'yaml'
require 'pry'

CONFIG = YAML.load_file('config.yml')

module MongoDB
  include Mongo

  def self.insert(doc)
    mongo_client = MongoClient.from_uri(CONFIG['mongodb']['uri'])
    coll = mongo_client.db(CONFIG['mongodb']['database'])
                       .collection(CONFIG['mongodb']['collection'])
    coll.drop
    doc.collect { |photo| coll.insert(photo) }
    mongo_client.close
  end
end

module Flickr
  FlickRaw.shared_secret = CONFIG['flickr']['shared_secret']
  FlickRaw.api_key = CONFIG['flickr']['api_key']

  def self.fetch_photoset(photoset_id = CONFIG['flickr']['default_photoset_id'])
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
    rescue StandardError => error
      puts "Oops, something went wrong: #{error}"
    end
  end

  class Photo
    def initialize(photo_hash)
      @title = photo_hash['title'].empty? ? "Untitled" : photo_hash['title']
      @thumbnail_image_url = photo_hash['url_z']
      @original_image_url = photo_hash['url_o']
      @photo_id = photo_hash['id']
    end

    def to_json
      {
        title: @title,
        thumbnail_image_url: @thumbnail_image_url,
        original_image_url: @original_image_url,
        flickr_id: @photo_id,
        permalink: permalink
      }
    end

    def permalink
      "http://www.flickr.com/photos/#{CONFIG['flickr']['username']}/#{@photo_id}/"
    end
  end
end

puts 'Please enter the photoset ID to fetch (leave blank for default):'
Flickr.fetch_photoset(gets.chomp)
