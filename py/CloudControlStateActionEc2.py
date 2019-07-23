""" Lambda function - start/stop/reboot ec2 """
import boto3

def CloudControlStateActionEc2(event, context):
    """ Lambda function - start/stop/reboot ec2 """

    # validate instance name
    ec2 = boto3.resource('ec2')
    ec2_client = boto3.client('ec2')
    response = ec2_client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [event["body"]["InstanceName"]]
            }
        ]
    )
    instance_list = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_list.append(instance['InstanceId'])

    if not instance_list:
        msg = "I cannot find the instance with name {}.".format(event["body"]["InstanceName"])
        return {"msg": msg}

    # I should fix it somehow...
    ec2_instance = ec2.instances.filter(InstanceIds=instance_list)

    commands = {
        'start': ['start', 'run'],
        'stop': ['stop'],
        'reboot': ['reboot', 'restart']
    }

    state = event["body"]["InstanceState"]

    if state != 'hibernate' and state not in commands:
        msg = "I do not know what to do, you use weird action to perform."
        return {"msg": msg}

    if state == 'hibernate':
        msg = "Hibernate is not working now. I am sorry."
        return {"msg": msg}

    for command_key in commands:
        aliases = commands[command_key]
        if state in aliases:
            # setattr(ec2_instance, command_key)
            getattr(ec2_instance, command_key).__call__()

    msg = (
        "{} against instance {} performed. "
        "Check the state of the instance shortly, in order to control, "
        "if {} action is successful.".format(
            event["body"]["InstanceState"], 
            event["body"]["InstanceName"], 
            event["body"]["InstanceState"]
        )

    )
    
    return {"msg": msg}