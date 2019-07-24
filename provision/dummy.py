import json

def cloud_control_state_action_ec2(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('Function under maintenance!')
    }