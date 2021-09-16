import { Controller } from 'stimulus';

export default class extends Controller {
  // static targets = [ 'test' ]

  connect() {
    console.log('Hello from reply_controller.js');
    console.log(this.element);
    // console.log(this.testTarget)
  }

  toggle(e) {
    e.preventDefault();
    const id = this.data.get('id');
    document.querySelector(`#${id}`).classList.toggle('d-none');
  }
}
