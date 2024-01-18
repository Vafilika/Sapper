<template>
  <div id="app">
    <SaperGame />
  </div>
</template>

<script>
import SaperGame from "./components/SaperGame.vue";
export default {
  name: "App",
  components: {
    SaperGame,
  },
};
</script>

<style>
#app {
  text-align: center;
}
</style>