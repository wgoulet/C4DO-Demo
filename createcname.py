import boto3
import pprint
import getopt
import sys
import datetime

def main(argv):
    dnsname = ''
    cname = ''
    hostedzoneid = ''
    try:
      opts, args = getopt.getopt(argv,"d:c:h:",["dnsName=","cname=","hostedzoneid="])
    except getopt.GetoptError:
      print('createcname.py -d <dnsname> -c <target cname> -h <Route53 hosted zone ID')
      sys.exit(2)

    for opt,arg in opts:
        if opt in ("-d","--dnsname"):
            dnsname = arg
        elif opt in ("-c","--cname"):
            cname = arg
        elif opt in ("-h","--hostedzoneid"):
            hostedzoneid = arg

    pprint.pprint(dnsname)
    pprint.pprint(cname)
    pprint.pprint(hostedzoneid)

    #pp = pprint.PrettyPrinter(indent=4)

    client = boto3.client('route53')
    response = client.list_resource_record_sets(
        HostedZoneId=hostedzoneid,
    )
    #pp.pprint(response)
    response = client.change_resource_record_sets(
        HostedZoneId=hostedzoneid,
        ChangeBatch={
            'Comment': 'Automated record',
            'Changes': [
                {
                    'Action': 'CREATE',
                    'ResourceRecordSet': {
                        'Name': dnsname,
                        'Type': 'CNAME',
                        'TTL': 300,
                        'ResourceRecords': [
                            {
                                'Value': cname,
                            },
                        ]
                    }
                },
            ]
        }
    )
    print(dnsname)


if __name__ == "__main__":
    main(sys.argv[1:])