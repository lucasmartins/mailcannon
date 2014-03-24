function () {
  emit(this.envelope_bag_id, { target_id: this.target_id, event: this.event });
}