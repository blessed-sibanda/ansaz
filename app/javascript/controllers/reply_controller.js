import { Controller } from 'stimulus';

export default class extends Controller {
  toggle(e) {
    e.preventDefault();
    const id = this.data.get('id');
    document.querySelector(`#${id}`).classList.toggle('d-none');
  }
}
