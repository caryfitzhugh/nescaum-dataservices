require 'aws-sdk'

HOST = 'nescaum-ccsc-dataservices.com'

def _curation_link(id)
  "https://repository.nescaum-ccsc-dataservices.com/curation/index.html#/resources/#{id}"
end

def send_broken_resources_email(resources)
  link_cache = {}
  broken_resources = resources.each_with_index.map do |r, i|
      puts "\n\nChecking #{i} / #{resources.length} (#{r.id})"
      STDOUT.flush
      broken = r.get_broken_links(link_cache: link_cache)
      puts "#{broken}"
      STDOUT.flush
      [r, broken]
  end.reject {|r| r[1].empty? }

  body = ""
  body += "<h2>#{broken_resources.length} Resources Found with Broken Links</h2>"
  body += "<ul>"
  body += broken_resources.map do |r|
            link = "<li>"
            link += "<a href='#{_curation_link(r[0].id)}'>#{r[0].title}</a>"
            link +=  "<ul>"
            link +=  r[1].map do |l|
                        "<li>#{l}</li>"
                      end.join("")
            link += "</ul>"
            link += "</li>"
            link
          end.join("\n")
  body += "</ul>"
  puts
  puts
  puts
  puts body
  puts
  puts
  puts

  CONFIG.emails.broken_links.each do |to|
    puts "Sending to #{to}"
    send_alert_email(to, "#{broken_resources.length} Broken-Link Resources") do
      body
    end
  end
end

def send_alert_email(to, subject)
  body = yield
  # Replace sender@example.com with your "From" address.
  # This address must be verified with Amazon SES.
  sender = "alert@" + HOST

  # The email body for recipients with non-HTML email clients.
  textbody = body

  # Specify the text encoding scheme.
  encoding = "UTF-8"

  _send_email( subject: subject,
               recipient: to,
               sender: sender,
               html: body)
end

def _send_email(subject:,
                recipient:,
                sender:,
                html: )
  awsregion = "us-east-1"

  # Create a new SES resource and specify a region
  ses = Aws::SES::Client.new(region: awsregion)

  encoding = 'UTF-8'

  # Try to send the email.
  begin
    text = html.gsub(/<\/?[^>]*>/, ' ').gsub(/\n\n+/, '\n').gsub(/^\n|\n$/, ' ').squeeze.strip
    # Provide the contents of the email.
    resp = ses.send_email({
      destination: {
        to_addresses: [
          recipient,
        ],
      },
      message: {
        body: {
          html: {
            charset: encoding,
            data: html
          },
          text: {
            charset: encoding,
            data: text
          },
        },
        subject: {
          charset: encoding,
          data: subject,
        },
      },
      source: sender,
    })
    puts "Email sent!"

  # If something goes wrong, display an error message.
  rescue Aws::SES::Errors::ServiceError => error
    puts "Email not sent. Error message: #{error}"
  end
end
