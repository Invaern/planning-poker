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
            this.handleEvent("save_username", ({user_name}) => {
                document.cookie = `user_name=${user_name};path=/;max-age=604800`;
            })

        },
        reconnected(){
            const user = getUserName();
            if (user) {
                this.pushEvent('reconnect_user', user)
            }

        }
    }
};

const user_name_regex = /(?:^|;)user_name=([^;]+)(?:;|$)/

function getUserName() {
    const cookie_match = document.cookie.match(user_name_regex);
    return cookie_match ? cookie_match[1] : null;

}