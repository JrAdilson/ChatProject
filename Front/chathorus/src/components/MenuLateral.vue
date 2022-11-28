<template>
    <div>
        <v-card class="navigator" height="100%" width="256">
            <v-navigation-drawer app color="#7B68EE" darkpermanent>
                <v-list>
                    <v-list-item class="navbar">
                        <h3 width="30px" style="padding-right: 15px; color: white"> <b> {{pessoa.id}} </b></h3>
                        <h3 width="30px"> {{pessoa.nome}} </h3>
                    </v-list-item>
                    <v-spacer></v-spacer>
                    <br>
                    <v-list-item v-for="chat in chats" :key="chat.id" link @click="$emit('change-chat', chat.id)">
                        <v-list-item-icon>
                            <v-icon color="white">{{ chat.id }}</v-icon>
                        </v-list-item-icon>
                        <v-list-item-content>
                            <v-list-item-title color="white">{{ chat.nome }}</v-list-item-title>
                        </v-list-item-content>
                        <br>
                    </v-list-item>
                    <v-list-item>
                        <v-btn @click="dialog = true">Adicionar</v-btn>
                    </v-list-item>
                </v-list>
                <template v-slot:append>
                    <div class="pa-2">
                        <v-btn style="color: white;" color="#BA55D3" block @click="getBack">Logout</v-btn>
                    </div>
                </template>
            </v-navigation-drawer>
        </v-card>
        <v-spacer></v-spacer>
        <v-dialog v-model="dialog" persistent>
            <v-card>
                <v-text-field
                    outlined
                    label="Nome"
                    v-model="chat.nome"
                ></v-text-field>
                <v-text-field
                    outlined
                    label="Descricao"
                    v-model="chat.descricao"
                ></v-text-field>
                <v-autocomplete
                    :items="this.participante.id + ' ' + this.participante.nome"
                    label="Participantes"
                    multiple
                    v-model="participante"
                ></v-autocomplete>
            </v-card>
            <v-btn @click="newChat" style="background-color:green; color: white">Adicionar</v-btn>
            <v-btn @click="dialog = false" style="background-color: red; color: white">Fechar</v-btn>
        </v-dialog>
    </div>
</template>

<script>
    export default {
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
                chats: [],
                dialog: false,
                chat: {
                    nome: '',
                    descricao: '',
                    participantes: ''
                },
                participantes: [],
                participante: [
                    {
                    id: null,
                    nome: ''
                    }
                ],
                lastChats: null
            }
        },
        async mounted() {
            this.pessoa = JSON.parse(localStorage.getItem('pessoa'));
            await this.$http.get(`/chats?idusuario=${this.pessoa.id}`).then(async (resp) => {
                localStorage.setItem('chats', JSON.stringify(resp.data));
                this.chats = resp.data
            });
            await this.$http.get(`/pessoa`).then((p) => {
                this.participantes = p.data
                this.participantes.forEach((part) => {
                    this.participante.id = part.id
                    this.participante.nome = part.nome
                })
                console.log(this.participante.id)
            })  
            await this.$http.get(`/chats?idusuario=${this.pessoa.id}`).then((resp) => {
                this.lastChats = resp.data.length
            })
        },
        methods: {
            async getBack() {
                this.$router.push('/');
            },
            async newChat() {
                let temp = '' + this.participante.id
                let participantesArray = [...temp].reduce((acc, n) => acc.concat(+n), [])
                console.log(participantesArray)
                const params = {nome: this.chat.nome, descricao: this.chat.descricao, idusuariologado: this.pessoa.id, participantes: this.participantesArray}
                await this.$http.post(`/chat`, JSON.stringify(params)).then((resp) => {
                    console.log(resp)
                    this.attGroups();
                })
            },
            async attGroups() {
                this.pessoa = JSON.parse(localStorage.getItem('pessoa'));
                await this.$http.get(`/chats?idusuario=${this.pessoa.id}`).then(async (resp) => {
                    localStorage.setItem('chats', JSON.stringify(resp.data));
                    this.chats = resp.data
                    console.log(this.chats)
                })
            },
        }
    }
</script>
<style scoped>

.navigator {
    margin-right: auto;
    height: 100% !important;
}

</style>