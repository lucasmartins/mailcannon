function () {
  values = {}
  values[this.event] = [this.target_id];

  if (this.event == 'bounce') {
  	if (this.type == 'bounce') {
		emit(this.envelope_bag_id, { hard_bounce: [ this.target_id ]})
	} else {
		emit(this.envelope_bag_id, { soft_bounce: [ this.target_id ]})
	}
  } else {
	emit(this.envelope_bag_id, values);
  }
}
