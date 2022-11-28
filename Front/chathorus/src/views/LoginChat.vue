<template>
<v-app>
   <div class="divMain">
      <div class="divImg">
         <v-img  height="100%" width="100%" cover src="../assets/background.jpg"> </v-img>
      </div>
      <div class="divLogin">
         <v-card style="height: 100%">
            <v-card-title style="text-align: center; margin-top: 20%">Chat Horus</v-card-title>
            <v-spacer></v-spacer>
            <v-card-text>
               <v-form style="margin-top: 15%; height: 100%;">
                  <div class="divInputs">
                     <v-text-field variant="outlined" placeholder="Digite o usuário" prepend-inner-icon="mdi-account"
                        name="usuario" label="Usuario" v-model="usuario">
                     </v-text-field>
                     <v-spacer></v-spacer>
                     <v-text-field variant="outlined" placeholder="Digite a senha" label="Senha" id="senha"
                        prepend-inner-icon="mdi-lock" name="senha" type="password" v-model="senha">
                     </v-text-field>
                  </div>
               </v-form>
            </v-card-text>
            <v-spacer></v-spacer>
            <div class="btnLogin">
               <v-btn style="width: 70%; height: 45px; color: white" color="#BA55D3" @click="loginAuth">Login</v-btn>
            </div>

            <div class="footer">
               <span>
                  Copyright (c) 2022 Adilson Junior
               </span>
               <v-spacer></v-spacer>
            </div>
         </v-card>
      </div>
   </div>
   </v-app>
</template>

<script>
export default {
   data() {
      return {
         usuario: '',
         senha: ''
      }
   },
   methods: {
      async loginAuth() {
         await this.$http.get(`/login?usuario=${this.usuario}&senha=${this.senha}`).then((resp) => {
            if (resp.status == 200) {
               localStorage.setItem('pessoa', JSON.stringify(resp.data.pessoa));
               this.$router.push('/chats');
            }
         })
      }
   }
}
</script>

<style scoped>
.divMain {
   display: flex;
   width: 100%;
   height: 100%;
}
.divImg {
   width: 69%;
   background: #0b0e17;
}
.divLogin {
   width: 40%;
}
.divInputs {
   display: inline-flexbox;
   align-items: center;
   justify-content: center;
   width: 95%;
}
.btnLogin {
   display: flex;
   align-items: center;
   justify-content: center;
   margin-top: 10%;
}
.footer {
   margin: auto;
   width: 100%;
   bottom: 0;
   position: fixed;
   color: rgb(97, 92, 92);
   font-size: 15px;
   margin: 0 0 5px 10px;
}
</style>