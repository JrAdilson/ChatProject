<template>
    <div style="display: flex; flex-direction: column; height: 100vh; border-radius: 50px">
        <header>
            <div class="user" style="height: 60px; background: #BA55D3;" app>
                <v-img style="margin-left: 20px" width="50" height="50" cover src="../assets/bg.png"></v-img>
            </div>
        </header>   
        <div class="group-box" style="background: #7B68EE; flex: 1; overflow-y: auto">
            <div class="text-outer">
                <v-row v-for="mensagem in mensagens" :key="mensagem.id">
                    <v-col :align="mensagem.proprioautor == 'sim' ? 'right' : 'left'">
                        <v-card style="margin-top: 5px; height: 150px; width: 300px;">
                            <v-card-title>
                                {{mensagem.nome}}
                            </v-card-title>
                            <v-card-text>
                                {{mensagem.mensagem}}
                            </v-card-text>
                            <v-card-actions>
                                {{ mensagem.data_texto }}
                            </v-card-actions>
                        </v-card>
                    </v-col>
                </v-row>
            </div>
        </div>
        <footer class="footer">
            <div style="min-height: 60px; background: #7B68EE">
                <div style="display: flex; padding: 15px">
                    <input class="input" type="text" style="width: 85%; border: 1px solid; border-radius: 4px; padding: 3px 6px;" v-model="inputMsg"/>
                    <v-btn style="background-color:#9370DB" class="pointer" prepend-inner-icon="mdi-send" alt="send" width="30" height="30" @click="sendMsg"><v-icon>mdi-send</v-icon></v-btn>
                </div>
            </div>
        </footer>
    </div>  
</template>

<script>

export default ({
    app: "ChatBox",
    props: {
        chatId: Number,
    },
    data() {
        return {
            pessoa: {
                id: null,
                nome: '',
                usuario: '',
                senha: '',
                foto: null,
                fone: '',
                cpf: '',
                email: '',
                descricao_perfil: null
            },
            mensagens: [],
            inputMsg: ''
        }
    },
    watch: {
        async chatId (e) {
            this.pessoa = JSON.parse(localStorage.getItem('pessoa'));
            this.getMsgs();
        }
    },
    methods: {
        async sendMsg() {
            const params = {idchat: this.chatId, idpessoa: this.pessoa.id, mensagem: this.inputMsg}
            await this.$http.post(`/mensagens-chat`, JSON.stringify(params)).then((resp) => {
                this.getMsgs()
                this.inputMsg = ''
            })
        },
        async getMsgs() {
            const url = `idchat=${this.chatId}&idusuariologado=${this.pessoa.id}&idmsg=0`;
            await this.$http.get(`/mensagens-chat?${url}`).then((msg) => {
                this.mensagens = msg.data
            })
        }
    }
})
</script>

<style scoped>
.user {
    margin-left: 350px;
    width: 50%;
}
.group-box {
    margin-left: 350px;
    width: 50%;
}
.footer {
    border: double;
    margin-left: 350px;
    width: 50%;
}
.pointer {
    cursor: pointer;
    box-shadow: rgba(6, 24, 44, 0.4) 0px 0px 0px 2px, rgba(6, 24, 44, 0.65) 0px 4px 6px -1px, rgba(255, 255, 255, 0.08) 0px 1px 0px inset;

}
.welcome {
    color: #635a5a;
    font-weight: 600;
    margin: 10px 0px 32px;
}
.br-50 {
    border-radius: 50%;
}
.header-image {
    float: left;
    margin-left: 10px;
    margin-top: 10px;
}
.text-outer {
    display: flex;
    flex-direction: column;
}
.text-inner {
    padding: 10px 10px 2px;
    border-radius: 0.5rem;
    width: 20%;
}
.textForm {
    background: teal;
    color: white;
    margin: 0% 0% 20px 70%;
}
.textTo {
    background: teal;
    color: black;
    margin: 0% 0% 20px 5%;
}
.pointer {
    cursor: pointer;
}
</style>
