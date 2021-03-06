<template>
  <div class="new-sentence">
    <div>
      <h2>{{ $t('webapp.evaluate.add_new_test_sentence') }}</h2>
      <span>
        {{ $t('webapp.evaluate.create_a_bench_of_test') }}
      </span>
    </div>
    <div class="new-sentence__form">
      <form
        @submit.prevent="submitSentence()">
        <div class="new-sentence__form__wrapper">
          <div>
            <b-field
              :message="errors.entities || errors.language"
            >
              <example-text-with-highlighted-entities-input
                id="tour-evaluate-step-2"
                ref="textInput"
                :is-previous-disabled="true"
                v-model="text"
                :is-step-blocked="text.length === 0"
                :entities="entities"
                :placeholder="$t('webapp.evaluate.enter_your_sentence_here')"
                @submit="onEnter()"
                @textSelected="setTextSelected($event)"
              />
            </b-field>
          </div>
          <div>
            <b-field
              id="tour-evaluate-step-3"
              :is-previous-disabled="true"
              :message="errors.non_field_errors"
              :is-step-blocked="(intent || '').length === 0">
              <b-select
                v-model="intent"
                :placeholder="$t('webapp.evaluate.intent')"
                expanded>
                <option
                  v-for="(intent, index) in repository.intents_list"
                  :value="intent"
                  :key="index">
                  {{ intent }}
                </option>
              </b-select>
            </b-field>
          </div>
          <div class="new-sentence__form__wrapper__submit-btn">
            <b-tooltip
              :label="validationErrors.join(', ')"
              :is-active="!isValid && validationErrors.length > 0"
              multilined
              type="is-dark">
              <b-button
                id="tour-evaluate-step-4"
                ref="saveSentenceButton"
                :is-next-disabled="true"
                :is-previous-disabled="true"
                :disabled="!shouldSubmit"
                :loading="submitting"
                :is-step-blocked="!blockedNextStepTutorial"
                type="is-primary"
                @click="submitSentence()">
                <slot v-if="!submitting">{{ $t('webapp.evaluate.submit') }}</slot>
              </b-button>
            </b-tooltip>
          </div>
        </div>
        <b-field
          :errors="errors.entities"
          class="new-sentence__form__entities"
        >
          <div class="columns">
            <div class="column is-one-third">
              <entities-input
                ref="entitiesInput"
                v-model="entities"
                :available-add-label="false"
                :repository="repository"
                :text="text"
                :text-selected="textSelected"
                :available-entities="entitiesList"
                :available-labels="availableLabels"
                :entities-for-edit="[]"
                :testing="testing"
                @entityAdded="onEntityAdded()"
                @entityEdited="onEditEntity($event)"
              />
            </div>
          </div>
        </b-field>
      </form>
    </div>
  </div>
</template>

<script>
import ExampleTextWithHighlightedEntitiesInput from '@/components/inputs/ExampleTextWithHighlightedEntitiesInput';
import EntitiesInput from '@/components/inputs/EntitiesInput';
import { mapActions, mapState, mapGetters } from 'vuex';
import { formatters } from '@/utils';


export default {
  name: 'NewEvaluateExample',
  components: {
    ExampleTextWithHighlightedEntitiesInput,
    EntitiesInput,
  },
  data() {
    return {
      textSelected: null,
      text: '',
      intent: null,
      entities: [],
      errors: {},
      submitting: false,
      entitiesList: [],
      testing: true,
      blockedNextStepTutorial: false,
      intentError: {},
    };
  },
  computed: {
    ...mapState({
      language: state => state.Repository.evaluateLanguage,
    }),
    ...mapGetters({
      repositoryVersion: 'getSelectedVersion',
      repository: 'getCurrentRepository',
    }),
    shouldSubmit() {
      return this.isValid && !this.submitting;
    },
    validationErrors() {
      const errors = [];

      if (!this.text) {
        errors.push(this.$t('webapp.evaluate.you_need_type_a_text'));
      }

      if (!this.intent) {
        errors.push(this.$t('webapp.evaluate.intent_is_required'));
      }

      return errors;
    },
    isValid() {
      return this.validationErrors.length === 0;
    },
    availableEntities() {
      const repositoryEntities = this.repository.entities_list || [];
      const entitiesFlat = this.entities.map(e => e.entity);
      return repositoryEntities
        .concat(entitiesFlat)
        .filter((entity, index, current) => (current.indexOf(entity) === index));
    },
    availableLabels() {
      const repositoryLabels = this.repository.labels_list || [];
      const labelsFlat = this.entities.map(e => e.label);
      return repositoryLabels
        .concat(labelsFlat)
        .filter(label => !!label)
        .filter((label, index, current) => (current.indexOf(label) === index));
    },
    data() {
      const {
        text,
        language,
        intent,
        entities,
      } = this;

      return {
        text,
        language,
        intent,
        entities,
      };
    },
  },
  watch: {
    intent() {
      if (!this.intent || this.intent.length <= 0) return;
      this.intent = formatters.bothubItemKey()(this.intent);
    },
  },
  mounted() {
    this.entitiesList = this.availableEntities;
  },
  methods: {
    ...mapActions([
      'newEvaluateExample',
    ]),
    onEnter() {
      if (this.shouldSubmit) this.submitSentence();
    },
    setTextSelected(value) {
      this.textSelected = value;
    },
    onEntityAdded() {
      if (this.$refs.textInput.clearSelected) {
        /* istanbul ignore next */
        this.$refs.textInput.clearSelected();
      }
    },
    onEditEntity(entity) {
      if (this.$refs.textInput.emitTextSelected) {
        /* istanbul ignore next */
        this.$refs.textInput.emitTextSelected({
          selectionStart: entity.start,
          selectionEnd: entity.end,
        });
      }
    },
    async submitSentence() {
      this.errors = {};
      this.submitting = true;
      if (this.$refs.entitiesInput.clearEntityForm) {
        this.$refs.entitiesInput.clearEntityForm();
      }

      try {
        await this.newEvaluateExample({
          repository: this.repository.uuid,
          repositoryVersion: this.repositoryVersion,
          ...this.data,
        });
        this.text = '';
        this.intent = null;
        this.entities = [];
        this.submitting = false;

        this.$emit('created');
        this.$emit('eventStep');
        this.blockedNextStepTutorial = !this.blockedNextStepTutorial;
        return true;
      } catch (error) {
        /* istanbul ignore next */
        const data = error.response && error.response.data;
        /* istanbul ignore next */
        if (data && data.non_field_errors && data.non_field_errors.length > 0) {
          /* istanbul ignore next */
          this.intentError = data;
          this.$buefy.toast.open({
            message: `${this.intentError.non_field_errors[0]}`,
            type: 'is-danger',
            duration: 5000,
          });
        }
        /* istanbul ignore next */
        this.submitting = false;
      }
      return false;
    },
  },
};
</script>

<style lang="scss" scoped>
@import '~@/assets/scss/variables.scss';

.new-sentence {
  width: 100%;
  margin: 2rem auto 0;

  &__form {

    &__wrapper {
      display: grid;
      grid-template-columns: 1.5fr 1fr .1fr;
      align-items: center;
      grid-gap: 1rem;
      padding: 1rem 0;

      @media (max-width: $mobile-width) {
        grid-template-columns: 1fr;
      }

      &__submit-btn {
        align-self: center;
        justify-self: flex-end;
      }
    }
  }
}
</style>
