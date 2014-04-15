function (key, values) {
  var result = {
    'posted': {
      'count': 0,
      'targets': []
    },
    'processed': {
      'count': 0,
      'targets': []
    },
    'delivered': {
      'count': 0,
      'targets': []
    },
    'open': {
      'count': 0,
      'targets': []
    },
    'click': {
      'count': 0,
      'targets': []
    },
    'deferred': {
      'count': 0,
      'targets': []
    },
    'spam_report': {
      'count': 0,
      'targets': []
    },
    'spam': {
      'count': 0,
      'targets': []
    },
    'unsubscribe': {
      'count': 0,
      'targets': []
    },
    'drop': {
      'count': 0,
      'targets': []
    },
    'hard_bounce': {
      'count': 0,
      'targets': []
    },
    'soft_bounce': {
      'count': 0,
      'targets': []
    },
    'unknown': {
      'count': 0,
      'targets': []
    }
  };

  values.forEach(function(value) {
    switch (value['event']) {
      case 'posted':
        result['posted']['count']++;
        result['posted']['targets'].push(value['target_id']);
      break;
      case 'processed':
        result['processed']['count']++;
        result['processed']['targets'].push(value['target_id']);
      break;
      case 'delivered':
        result['delivered']['count']++;
        result['delivered']['targets'].push(value['target_id']);
      break;
      case 'open':
        result['open']['count']++;
        result['open']['targets'].push(value['target_id']);
      break;
      case 'click':
        result['click']['count']++;
        result['click']['targets'].push(value['target_id']);
      break;
      case 'deferred':
        result['deferred']['count']++;
        result['deferred']['targets'].push(value['target_id']);
      break;
      case 'spam_report':
        result['spam_report']['count']++;
        result['spam_report']['targets'].push(value['target_id']);
      break;
      case 'spam':
        result['spam']['count']++;
        result['spam']['targets'].push(value['target_id']);
      break;
      case 'unsubscribe':
        result['unsubscribe']['count']++;
        result['unsubscribe']['targets'].push(value['target_id']);
      break;
      case 'drop':
        result['drop']['count']++;
        result['drop']['targets'].push(value['target_id']);
      break;
      case 'bounce':
        if(value['type'] == "bounce"){
          result['hard_bounce']['count']++;
          result['hard_bounce']['targets'].push(value['target_id']);
        }
        else {
          result['soft_bounce']['count']++;
          result['soft_bounce']['targets'].push(value['target_id']);
        }  
      break;
      default:
        result['unknown']['count']++;
        result['unknown']['targets'].push(value['target_id']);
      break;
    }
  });
  return result;
}