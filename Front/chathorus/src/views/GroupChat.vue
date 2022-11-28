<template>
    <v-app>
        <MenuLateral @change-chat="changeChat"/>
        <ChatBox :chatId="chatId"/>  
    </v-app>
</template>

<script>
    import MenuLateral from '@/components/MenuLateral.vue'
    import ChatBox from '@/components/ChatBox.vue'
    export default {
        components: {
            ChatBox,
            MenuLateral,
        },
        data() {
            return {
                chatId: null
            }
        },
        methods: {
            changeChat(e) {
                this.chatId = e;
            }
        },
    }
</script>

<style scoped>
</style>