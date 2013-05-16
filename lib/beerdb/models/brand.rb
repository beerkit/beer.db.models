# encoding: UTF-8

module BeerDb::Models

class Brand < ActiveRecord::Base

  # NB: use extend - is_<type>? become class methods e.g. self.is_<type>?
  extend TextUtils::ValueHelper  # e.g. self.find_key_n_title, self.is_year?, self.is_region?, is_address?, is_taglist? etc.

  belongs_to :country, :class_name => 'WorldDb::Models::Country', :foreign_key => 'country_id'
  belongs_to :region,  :class_name => 'WorldDb::Models::Region',  :foreign_key => 'region_id'
  belongs_to :city,    :class_name => 'WorldDb::Models::City',    :foreign_key => 'city_id'

  belongs_to :brewery, :class_name => 'BeerDb::Models::Brewery',  :foreign_key => 'brewery_id'

  has_many   :beers,   :class_name => 'BeerDb::Models::Beer',     :foreign_key => 'brand_id'

  validates :key, :format => { :with => /^[a-z][a-z0-9]+$/, :message => 'expected two or more lowercase letters a-z or 0-9 digits' }


  def self.create_or_update_from_values( values, more_attribs = {} )
    attribs, more_values = find_key_n_title( values )
    attribs = attribs.merge( more_attribs )

    Brand.create_or_update_from_attribs( attribs, more_values )
  end


  def self.create_or_update_from_attribs( attribs, values )

    ## fix: add/configure logger for ActiveRecord!!!
    logger = LogKernel::Logger.root

    ## check for grades (e.g. ***/**/*) in titles (will add attribs[:grade] to hash)
    ## if grade missing; set default to 4; lets us update overwrite 1,2,3 values on update
    attribs[:grade] ||= 4

    rec = Brand.find_by_key( attribs[:key] )

    if rec.present?
      logger.debug "update Brand #{rec.id}-#{rec.key}:"
    else
      logger.debug "create Brand:"
      rec = Brand.new
    end
      
    logger.debug attribs.to_json

    rec.update_attributes!( attribs )
  end

end # class Brand

end # module BeerDb::Models
