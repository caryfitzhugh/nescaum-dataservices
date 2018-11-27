require 'aws-sdk'

HOST = 'nescaum-ccsc-dataservices.com'

def send_alert_email(to, subject, html)
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
                text:,
                html: )
  awsregion = "us-east-1"

  # Create a new SES resource and specify a region
  ses = Aws::SES::Client.new(region: awsregion)

  encoding = 'UTF-8'

  # Try to send the email.
  begin
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
            data: html || "<h1>#{subject}</h1><p>#{text}</p>",
          },
          text: {
            charset: encoding,
            data: text,
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
