<template>
  <div
    :class="[
      'bh-card',
      !!shadow
        ? `bh-card--shaded-${shadow}`
        : 'bh-card--shaded',
      noBorder
        ? 'bh-card--no-border'
        : '',
    ]"
  >
    <div class="bh-card__main">
      <slot />
    </div>
    <slot
      v-if="$slots.append"
      name="append"
      class="bh-card__append"
    />
  </div>
</template>

<script>
export default {
  name: 'BhCard',
  props: {
    shadow: {
      type: String,
      default: null,
    },
    noBorder: {
      type: Boolean,
      default: false,
    },
  },
};
</script>

<style lang="scss">
@import '@scss/colors.scss';
@import '@scss/variables.scss';
@import '@scss/shadow.scss';


.bh {
  &-card {
    @include shadow();

    display: flex;
    flex-direction: row;
    background-color: white;
    border: 1px solid $color-grey;
    border-radius: $radius-normal;

    &--no-border {
      border: 1px solid transparent;
    }

    &__main {
      flex-grow: 1;
    }

    &__append {
      flex-grow: 0;
    }
  }
}
</style>
