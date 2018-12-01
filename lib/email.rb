require 'aws-sdk'

HOST = 'nescaum-ccsc-dataservices.com'

def send_broken_resources_email(resources)
  link_cache = {}
  broken_resources = resources.map do |r|
      [r, r.get_broken_links(link_cache: link_cache)]
  end.reject {|r| r[1].empty? }


  CONFIG.emails.broken_links.each do |to|
    send_alert_email(to, "#{broken_resources.length} Broken-Link Resources") do
      <<-EMAIL_BODY
        <h2>#{broken_resources.length} Resources Found with Broken Links</h2>
        <ul>
          #{broken_resources.map do |r|
            "<li>#{r[0].id} #{r[0].title}" +
              "<ul>" +
                r[1].map do |l|
                  "<li>#{l}</li>"
                end.join("")
              + "</ul>"+
            "</li>"
          end
          }
        </ul>
      EMAIL_BODY
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
    text = html.gsub(/<\/?[^>]*>/, ' ').gsub(/\n\n+/, '\n').gsub(/^\n|\n$/, ' ').squish
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
