import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'about',
    'aboutLink',
    'questions',
    'questionsLink',
    'answers',
    'answersLink',
    'requests',
    'requestsLink',
  ];

  reset() {
    this.element.querySelectorAll('ul>li>a.nav-link').forEach((item) => {
      item.classList.remove('active');
    });
    this.element.querySelectorAll('.tab-content>.tab-pane').forEach((item) => {
      item.classList.remove('active');
      item.classList.remove('show');
    });
  }

  about() {
    this.reset();
    this.aboutLinkTarget.classList.add('active');
    this.aboutTarget.classList.add('active');
    this.aboutTarget.classList.add('show');
  }

  answers() {
    this.reset();
    this.answersLinkTarget.classList.add('active');
    this.answersTarget.classList.add('active');
    this.answersTarget.classList.add('show');
  }

  questions() {
    this.reset();
    this.questionsLinkTarget.classList.add('active');
    this.questionsTarget.classList.add('active');
    this.questionsTarget.classList.add('show');
  }

  requests() {
    this.reset();
    this.requestsLinkTarget.classList.add('active');
    this.requestsTarget.classList.add('active');
    this.requestsTarget.classList.add('show');
  }
}
