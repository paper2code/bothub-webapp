<template>
  <b-tooltip
    :active="!!helpText"
    :label="helpText"
    multilined
    class="blocked">
    <p
      v-show="!editable"
      class="has-text-centered"><small> {{ roleLabel }} </small></p>
    <b-select
      v-show="editable"
      v-model="role"
      v-bind="$attrs"
      expanded>
      <option
        v-for="(label, value) in roles"
        :value="value"
        :key="value">
        {{ $t(`webapp.roles.${label.toLowerCase()}`) }}
      </option>
    </b-select>
  </b-tooltip>
</template>

<script>
import {
  ROLES,
} from '@/utils';

export default {
  name: 'RoleSelect',
  props: {
    value: {
      type: [Number, String],
      default: null,
    },
    editable: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      roles: ROLES,
      role: this.value,
    };
  },
  computed: {
    helpText() {
      if (this.role === null) {
        return null;
      }

      return this.$t(`webapp.roles.${this.roles[this.role].toLowerCase()}_description`);
    },
    roleLabel() {
      if (this.role === null) {
        return null;
      }

      return this.$t(`webapp.roles.${this.roles[this.role].toLowerCase()}`);
    },
  },
  watch: {
    value() {
      this.role = this.value;
    },
    role() {
      this.$emit('input', this.role);
    },
  },
};
</script>

<style lang="scss" scoped>
.blocked {
  display: block;
}
</style>
