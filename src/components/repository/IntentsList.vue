<template>
  <div class="intent-list">
    <div class="intent-list__content">
      <div class="intent-list__content__descriptions">
        <h1> <strong>{{ $t('webapp.intent.title') }}</strong> </h1>
        <p> <strong>"</strong> {{ intent }} <strong>"</strong> </p>
      </div>
      <!-- <div>
        <b-button
          v-if="!editSentences"
          ref="editEntityEvent"
          class="intent-list__content__buttonEdit"
          @click.native="editOptionsEntity()">{{ $t('webapp.intent.edit_button') }}</b-button>
        <b-button
          v-else
          ref="saveEntityEvent"
          class="intent-list__content__buttonSave"
          @click.native="saveEdition()">{{ $t('webapp.intent.save_button') }}</b-button>
      </div> -->
    </div>
    <div class="intent-list__header__options">
      <p> {{ $tc('webapp.intent.description', totalSentences) }}</p>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  name: 'IntentsList',
  props: {
    IntentsList: {
      type: Object,
      default: null,
    },
    repository: {
      type: Object,
      default: () => {},
    },
  },
  data() {
    return {
      editSentences: false,
      intent: this.$route.params.intent,
      errors: {},
    };
  },
  computed: {
    ...mapGetters({
      repositoryVersion: 'getSelectedVersion',
      repositoryList: 'getCurrentRepository',
    }),
    totalSentences() {
      if (this.IntentsList !== null) {
        return this.IntentsList.total;
      }
      return 0;
    },
  },
  mounted() {
    // this.getEntitiesName();
  },
  methods: {
    // editOptionsEntity() {
    //   this.editSentences = !this.editSentences;
    //   this.$emit('setAllEntities', this.allEntities);
    // },
    // saveEdition() {
    //   this.editOptionsEntity();
    // },
  },
};
</script>

<style lang="scss" scoped>
@import '~@/assets/scss/colors.scss';
@import '~@/assets/scss/variables.scss';
.intent-list {
    margin: 0.4rem;
    margin-bottom: $between-subtitle-content;
      &__options{
        p{
          font-size: $font-size
        }
      }

    &__content {
      display: flex;
      justify-content: space-between;
      align-items: center;

      &__descriptions{
        display: flex;

        p{
          font-size: 20px;
          margin-left: 1rem;
          margin-top: -0.01rem;
          strong{
            font-size: 25px;
          }
        }

        &__tag{
        margin: 0.2rem 0.5rem;
        border-radius: 1rem;
        padding: 0 1.1rem;

          div {
            font-size: 1.12rem;
            font-family: $font-family;
            margin-bottom: .1rem;
          }
        }
         @media screen and (max-width: 40em) {
            display: flex;
            flex-direction: column;
          }
      }

      h1{
        font-size: 1.75rem;
      }

        &__buttonEdit{
          width: 9.9rem;
          margin-bottom:0.5rem;
          background-color: $color-primary;
          color: #FFFFFF;
        }
        &__buttonSave{
          width: 9.9rem;
          margin-bottom:0.5rem;
          background-color: $color-secondary-light;
          color: #FFFFFF;
        }
    }

    &__notification {

      margin: 0.5rem;

         @media screen and (max-width: 50em) {
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          align-items: center;
      }
    }
}
</style>
