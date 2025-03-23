require "sinatra"
require "mechanize"

helpers do
  def bin_colour_and_kind(collection_type:)
    case collection_type
    when "Refuse Bin for Non-Recycling"
      ["green", "normal rubbish"]
    when "Blue-Top Bin for Recycling"
      ["blue", "recycling"]
    end
  end

  def get_postcode_from_full_address
    ENV.fetch("BINS_ADDRESS").split(",").last.strip
  end

  def strip_punctuation_from_address
    ENV.fetch("BINS_ADDRESS").gsub(/[^0-9a-z ]/i, '')
  end
end

get '/' do
  agent = Mechanize.new
  addresses = {}

  user_address = strip_punctuation_from_address
  user_postcode = get_postcode_from_full_address

  agent.get("https://www.horsham.gov.uk/waste-recycling-and-bins/household-bin-collections/check-your-bin-collection-day") do

    postcode_form = agent.page.form_with(name: "Search")
    postcode_form.fields.first.value = user_postcode

    select_address_page = agent.submit(postcode_form, postcode_form.buttons.first)

    select_address_form = select_address_page.form_with(name: "Searching")
    select_address_form.fields.first.options.each_with_object(addresses) do |option, addresses|
      addresses[option.value.to_i] = option.text.strip
    end
    select_address_form.field_with(name: "uprn").value = addresses.key(user_address)

    details = agent.submit(select_address_form, select_address_form.buttons.first)

    @this_week = {
      collection_day:  details.search("td")[0].children.first.text.strip,
      collection_date: details.search("td")[1].children.first.text.strip,
      collection_type: details.search("td")[2].children.first.text.strip,
    }

    @bin_colour, @bin_kind = bin_colour_and_kind(collection_type: @this_week[:collection_type])
  end

  erb :index
end
