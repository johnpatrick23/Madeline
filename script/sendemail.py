import sendgrid
import os
import yaml
import sys
import getopt
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import *


def send_email(apikey, from_email, to_email, cc_email, subject, message):
    sg = sendgrid.SendGridAPIClient(apikey)
    content = Content("text/plain", message)

    to_emails = []
    for to in to_email:
        to_emails.append(To(to))

    cc_emails = []
    for cc in cc_email:
        cc_emails.append(Cc(cc))

    mail = Mail(Email(from_email), to_emails, subject, content)
    mail.add_cc(cc_emails)

    mail_json = mail.get()

    response = sg.client.mail.send.post(request_body=mail_json)

    print(response.status_code)
    print(response.headers)


if __name__ == '__main__':
    argv = sys.argv[1:]
    message = ''
    subject = ''
    try:
        opts, args = getopt.getopt(argv, "hm:s:", ["message=", "subject="])
    except getopt.GetoptError:
        print('Usage:')
        print('python sendemail.py -m message -s subject')
        print('python sendemail.py --message message --subject subject')
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print('Usage:')
            print('python sendemail.py -m message -s subject')
            print('python sendemail.py --message message --subject subject')
            sys.exit()
        elif opt in ("-m", "--message"):
            message = arg
        elif opt in ("-s", "--subject"):
            subject = arg

    with open('./../config/config.yml') as yml:
        config = yaml.safe_load(yml)

    apikey = config['SENDGRID']['EMAIL_APIKEY']
    from_email = config['SENDGRID']['EMAIL_FROM']
    to_email = config['SENDGRID']['EMAIL_TO']
    cc_email = config['SENDGRID']['EMAIL_CC']
    print(message)
    print(subject)
    send_email(apikey, from_email, to_email, cc_email, subject, message)

