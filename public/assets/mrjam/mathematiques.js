/* Raccord KaTeX existant, trust=false ; aucune présentation ordinaire. */
(() => {
  "use strict";
  class MathTex extends HTMLElement {
    static get observedAttributes() {
      return ["formula", "display-mode"];
    }
    connectedCallback() {
      this.render();
    }
    attributeChangedCallback() {
      if (this.isConnected) this.render();
    }
    render() {
      const formula = this.getAttribute("formula") || "";
      if (window.katex) {
        window.katex.render(formula, this, {
          displayMode: this.hasAttribute("display-mode"),
          throwOnError: false,
          strict: "warn",
          trust: false,
          output: "htmlAndMathml",
        });
      } else {
        this.textContent = formula;
      }
    }
  }
  if (!customElements.get("math-tex"))
    customElements.define("math-tex", MathTex);
})();
