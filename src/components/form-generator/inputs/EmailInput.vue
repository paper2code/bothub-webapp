<template>
  <b-input
    :maxlength="max_length"
    :has-counter="showMaxLength"
    v-model="value"
    :placeholder="labelPlaceholder"
    type="email"
    @input="update()" />
</template>

<script>

export default {
  props: {
    max_length: {
      type: Number,
      default: null,
    },
    labelPlaceholder: {
      type: String,
      default: '',
    },
    showMaxLength: {
      type: Boolean,
      default: true,
    },
    initialData: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      value: this.initialData,
    };
  },
  mounted() {
    this.update();
  },
  methods: {
    update() {
      this.$emit('input', this.value);
    },
  },
};
</script>
