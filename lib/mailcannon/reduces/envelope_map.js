function () {
  emit(this.envelope_id, { target_id: this.target_id, event: this.event });
}