export const Hooks = {
    NotBlank:  {
        mounted() {
            this.el.addEventListener('input', _e => {
                if (this.el.value) {
                    this.el.value = this.el.value.trimStart()
                }
            })
        }
    }
};