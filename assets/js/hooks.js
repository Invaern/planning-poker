export const Hooks = {
    NotBlank:  {
        mounted() {
            this.el.addEventListener('input', _e => {
                if (this.el.value) {
                    this.el.value = this.el.value.trimStart()
                }
            })
        }
    },
    CookiesHandler: {
        mounted() {
            this.handleEvent("clear_cookies", (_) => {
                document.cookie = `user_name=expired;path=/;max-age=0`;
            });
            this.handleEvent("set_username", ({user_name}) => {
                document.cookie = `user_name=${user_name};path=/;max-age=604800`;
            })
        }
    }
};