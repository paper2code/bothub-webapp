<template>
  <repository-view-base
    :repository="repository"
    :error-code="errorCode">

    <div v-if="repository">
      <div v-if="authenticated">
        <div
          v-if="repository.authorization.can_contribute || repository.authorization.can_translate">
          <div class="translate-description">
            <h1>{{ $t('webapp.translate.title_translate') }}</h1>
            <p>{{ $t('webapp.translate.subtitle_translate') }}</p>
          </div>

          <div class="repository-translate">
            <div class="repository-translate__field">
              <div class="repository-translate__field__item">
                <b-field
                  :label="$t('webapp.translate.translate_from')"
                  custom-class="repository-translate__field__item__label">
                  <language-select
                    id="tour-translate-step-1"
                    :is-previous-disabled="true"
                    :is-step-blocked="translate.from === null"
                    v-model="translate.from" />
                </b-field>
              </div>
              <div class="repository-translate__translate-arrow-icon">
                <div class="field">
                  <label class="label">&nbsp;</label>
                  <b-icon
                    icon="chevron-right"
                    size="is-medium" />
                </div>
              </div>
              <div class="repository-translate__field__item">
                <b-field
                  :label="$t('webapp.translate.translate_to')"
                  custom-class="repository-translate__field__item__label">
                  <language-select
                    id="tour-translate-step-2"
                    v-model="translate.to"
                    :is-step-blocked="(translate.to === null || loadingList) || !hasPhrases"
                    :exclude="[translate.from]"/>
                </b-field>
              </div>
            </div>
          </div>
          <div
            id="tour-translate-step-6"
            :is-previous-disabled="true"
            class="repository-translate__translateButtons">

            <b-button
              :class="{'is-primary':!!translate.from && !!translate.to}"
              class="repository-translate__buttons repository-translate__unableButton"
              @click="checkLanguageToImport()">
              {{ $t('webapp.translate.import_title') }}
            </b-button>

            <b-button
              :class="{'is-primary':!!translate.from && !!translate.to}"
              class="repository-translate__buttons repository-translate__unableButton"
              @click="checkLanguageToExport()">
              {{ $t('webapp.translate.export_title') }}
            </b-button>

          </div>
          <div
            v-if="!!translate.from && !!translate.to">
            <b-modal
              :active.sync="isImportFileVisible"
              :destroy-on-hide="false"
              :can-cancel="false"
              has-modal-card
              trap-focus
              aria-role="dialog"
              aria-modal>
              <div
                class="modal-card repository-translate__modalStyle">
                <header class="modal-card-head">
                  <p class="modal-card-title">{{ $t('webapp.translate.import_title') }}</p>
                </header>
                <section class="modal-card-body">
                  <b-field
                    class="custom-file-upload">
                    <div class="custom-file-upload__input">
                      <b-upload
                        v-model="translationFile"
                      >
                        <a class="button custom-file-upload__input__button">
                          <b-icon
                            icon="upload"
                            type="is-white"/>
                        </a>
                      </b-upload>

                      <div
                        v-if="translationFile"
                        class="custom-file-upload__input__file">
                        {{ translationFile.name }}

                        <div
                          class="custom-file-upload__input__icon"
                          @click="removeSelectedFile">
                          <b-icon
                            icon="close-circle"
                            custom-size="mdi-18px"
                          />
                        </div>
                      </div>

                      <div
                        v-else
                        class="custom-file-upload__input__file">
                        <span>{{ $t('webapp.translate.import_field_text') }}</span>
                      </div>
                    </div>
                    <p>{{ errorMessage }}</p>

                  </b-field>
                </section>
                <footer class="modal-card-foot">
                  <div class="repository-translate__modalStyle__styleButton">
                    <b-button
                      class="modalButton"
                      type="is-white"
                      @click="closeImportModal()">
                      {{ $t('webapp.translate.import_button_cancel') }}
                    </b-button>

                    <b-button
                      :loading="waitDownloadFile"
                      :disabled="translationFile === null"
                      class="modalButton"
                      type="is-primary"
                      @click="importTranslation()">
                      {{ $t('webapp.translate.import_button') }}
                    </b-button>
                  </div>
                </footer>
              </div>
            </b-modal>

            <b-modal
              :active.sync="isExportFileVisible"
              :destroy-on-hide="false"
              :can-cancel="false"
              has-modal-card
              trap-focus
              aria-role="dialog"
              aria-modal>
              <div
                class="modal-card repository-translate__modalStyle">
                <header class="modal-card-head">
                  <p class="modal-card-title">{{ $t('webapp.translate.export_title') }}</p>
                </header>
                <section class="modal-card-body">
                  <div class="repository-translate__selection__section">
                    <b-field>
                      <b-select
                        v-model="allTranslations"
                        expanded
                        size="is-medium"
                        class="repository-translate__selection__section__expanded"
                        placeholder="Select a name">
                        <option
                          v-for="option in exportOption"
                          :value="option.value"
                          :key="option.id">
                          {{ option.label }}
                        </option>
                      </b-select>
                    </b-field>
                  </div>
                </section>

                <footer class="modal-card-foot">
                  <div class="repository-translate__modalStyle__styleButton">
                    <b-button
                      class="modalButton"
                      type="is-white"
                      @click="closeExportModal()">
                      {{ $t('webapp.translate.import_button_cancel') }}
                    </b-button>
                    <b-button
                      :loading="waitDownloadFile"
                      type="is-primary"
                      class="modalButton"
                      @click="exportTranslation()">
                      {{ $t('webapp.translate.export_button') }}
                    </b-button>
                  </div>
                </footer>
              </div>
            </b-modal>
            <hr>
            <div class="repository-translate__list">
              <div class="repository-translate__list__search">
                <filter-examples
                  :intents="repository.intents_list"
                  :entities="repository.entities_list"
                  @queryStringFormated="onSearch($event)"/>
              </div>
              <translate-list
                :update="translate.update"
                :repository="repository"
                :query="query"
                :from="translate.from"
                :to="translate.to"
                @translated="examplesTranslated()"
                @eventStep="dispatchClick()"
                @isLoadingContent="loadingList = $event"
                @listPhrase="checkPhraseList($event)"/>
            </div>

          </div>
        </div>
        <authorization-request-notification
          v-else
          :available="!repository.available_request_authorization"
          :repository-uuid="repository.uuid"
          @onAuthorizationRequested="updateRepository(false)" />
      </div>
      <div v-else>
        <b-notification
          :closable="false"
          class="is-info"
          role="alert">
          {{ $t('webapp.translate.login') }}
        </b-notification>
        <login-form hide-forgot-password />
      </div>
    </div>
    <tour
      v-if="activeTutorial === 'translate'"
      :step-count="1"
      :next-event="eventClick"
      :finish-event="eventClickFinish"
      name="translate" />
  </repository-view-base>
</template>

<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import RepositoryViewBase from '@/components/repository/RepositoryViewBase';
import LanguageSelect from '@/components/inputs/LanguageSelect';
import TranslateList from '@/components/translate/TranslateList';
import TranslationsList from '@/components/translate/TranslationsList';
import LoginForm from '@/components/auth/LoginForm';
import RepositoryBase from './Base';
import FilterExamples from '@/components/repository/repository-evaluate/example/FilterEvaluateExample';
import { exampleSearchToDicty, exampleSearchToString } from '@/utils/index';
import AuthorizationRequestNotification from '@/components/repository/AuthorizationRequestNotification';
import Tour from '@/components/Tour';

export default {
  name: 'RepositoryTranslate',
  components: {
    FilterExamples,
    RepositoryViewBase,
    LanguageSelect,
    TranslateList,
    TranslationsList,
    LoginForm,
    AuthorizationRequestNotification,
    Tour,
  },
  extends: RepositoryBase,
  data() {
    return {
      translationFile: null,
      isExportFileVisible: false,
      isImportFileVisible: false,
      waitDownloadFile: false,
      translate: {
        from: null,
        to: null,
        update: false,
      },
      toLanguage: null,
      query: {},
      querySchema: {},
      errors: '',
      errorMessage: '',
      eventClick: false,
      eventClickFinish: false,
      loadingList: true,
      hasPhrases: false,
      allTranslations: false,
      exportOption: [
        { id: 0, label: this.$t('webapp.translate.export_all_sentences'), value: false },
        { id: 1, label: this.$t('webapp.translate.export_only_translated'), value: true },
      ],
    };
  },
  computed: {
    ...mapState({
      selectedRepository: state => state.Repository.selectedRepository,
    }),
    ...mapGetters([
      'activeTutorial',
    ]),
  },
  watch: {
    isImportFileVisible() {
      if (this.isImportFileVisible === false) {
        this.errorMessage = '';
        return this.removeSelectedFile();
      }
      return '';
    },
  },
  methods: {
    ...mapActions([
      'getRepository',
      'exportTranslations',
      'importTranslations',
    ]),
    async exportTranslation() {
      this.waitDownloadFile = !this.waitDownloadFile;
      try {
        const xlsFile = await this.exportTranslations({
          repositoryUuid: this.selectedRepository.uuid,
          versionUUID: this.selectedRepository.repository_version_id,
          fromLanguage: this.translate.from,
          toLanguagem: this.translate.to,
          statusTranslation: !this.allTranslations,
        });
        this.forceFileDownload(xlsFile);
        this.$buefy.toast.open({
          message: 'Downloading File',
          type: 'success',
        });
      } catch (error) {
        this.errors = error;
      }
      this.waitDownloadFile = !this.waitDownloadFile;
      return false;
    },
    async importTranslation() {
      this.waitDownloadFile = !this.waitDownloadFile;
      const formData = new FormData();
      formData.append('file', this.translationFile);
      formData.append('language', this.translate.to);

      try {
        const importDownload = await this.importTranslations({
          repositoryUuid: this.selectedRepository.uuid,
          versionUUID: this.selectedRepository.repository_version_id,
          formData,
        });
        this.forceFileDownload(importDownload);
      } catch (error) {
        this.errorMessage = this.$t('webapp.translate.import_select_error');
      }
      this.waitDownloadFile = !this.waitDownloadFile;
      this.translationFile = null;
      return false;
    },
    dispatchClick() {
      this.eventClick = !this.eventClick;
    },
    dispatchFinish() {
      this.eventClickFinish = !this.eventClickFinish;
    },
    forceFileDownload(response) {
      const blob = new Blob([response.data], { type: response.headers['content-type'] });
      const result = document.createElement('a');
      result.href = window.URL.createObjectURL(blob);
      result.download = 'bothub.xlsx';
      result.click();
    },
    checkLanguageToImport() {
      if (this.translate.from && this.translate.to) {
        if (this.activeTutorial === 'translate') {
          return;
        }
        this.isImportFileVisible = true;
      }
    },
    checkLanguageToExport() {
      if (this.translate.from && this.translate.to) {
        if (this.activeTutorial === 'translate') {
          return;
        }
        this.isExportFileVisible = true;
      }
    },
    removeSelectedFile() {
      this.translationFile = null;
    },
    examplesTranslated() {
      this.translate.update = !this.translate.update;
    },
    async checkPhraseList(list) {
      if (this.activeTutorial === 'translate') {
        const checkList = await list.getAllItems();
        if (checkList.length === 0) {
          this.hasPhrases = false;
          return;
        }
        this.hasPhrases = true;
      }
    },
    closeImportModal() {
      this.isImportFileVisible = false;
      this.errorMessage = '';
      this.removeSelectedFile();
    },
    closeExportModal() {
      this.isExportFileVisible = false;
    },
    onSearch(value) {
      Object.assign(this.querySchema, value);

      if (!this.querySchema.intent) {
        delete this.querySchema.intent;
      }
      if (!this.querySchema.entity) {
        delete this.querySchema.entity;
      }
      if (!this.querySchema.label) {
        delete this.querySchema.label;
      }
      const formattedQueryString = exampleSearchToString(this.querySchema);
      this.query = exampleSearchToDicty(formattedQueryString);
    },
  },
};
</script>

<style lang="scss">
@import '~@/assets/scss/colors.scss';
@import '~@/assets/scss/variables.scss';

.translate-description{
  margin-left: 0.8rem;
  h1{
    font-size: 28px;
    margin-bottom: $between-title-subtitle;
    color: $color-fake-black;
    font-family: $font-family;
    font-weight: $font-weight-bolder;
  }
  p{
    margin-bottom: $between-subtitle-content;
    color: $color-fake-black;
    font-family: $font-family;
    font-size: $font-size
  }
}
.repository-translate {
  background-color: $color-white;
  display:flex;
   flex-direction: column;
  justify-content: space-around;
  align-items: center;

  &__field {
    display: flex;
    padding: 0.25rem;
    width: 100%;
    &__item {
      margin: 0.5rem;
      width: 50%;
        &__label{
        font-weight: $font-weight-normal;
        }
    }
  }

  &__translate-arrow-icon {
    align-self: center;
    color: $color-grey-dark;
  }
  &__list{
    margin-left: 0.3rem;
  &__search {
    margin: 0.5rem;
  }
  }

  &__requestAuthorization{
        color: $color-fake-black;
        font-weight: $font-weight-medium;
        text-align: center;
        float: right
  }

&__selection{

    &__section{
      display: flex;
      justify-content: space-around;
      width: 100%;
      margin: auto;
      align-items: center;

      p{
        margin-left: 1rem;
      }

      &__expanded{
        width: 22rem;
      }
    }
}
&__modalStyle{
  width: 26.5rem;
  &__styleButton{
    width:100%;
    display: flex;
    justify-content: flex-end;
    align-items: center;

    .modalButton {
      cursor: pointer;
      border: 1px solid #dbdbdb;
      text-align: center;
      border-radius: 4px;
      box-shadow: none;
      font-weight: bold;

      &:hover{
        border: 1px solid #c2c2c2;
      }
    }
  }
}

  &__buttons{
    width: 179px;
    height: 40px;
    margin: 0.5rem;
    font-family: $font-family;
    font-size: $font-size;
    font-weight: $font-weight-bolder;
    box-shadow: 0px 3px 6px #00000029;
    border-radius: 6px;
    background-color: $color-primary;

    display: flex;
    justify-content: center;
    align-items: center;
  }

  &__translateButtons{
    display: flex;
    width: 385px;
    margin: 1rem 0.3rem;
    margin-left: 0.8rem;
    border-radius: 5px;
    justify-content: space-between;
  }
  &__unableButton{
    background-color:$color-grey;
    color: $color-white;
    border: 2px solid #D5D5D5;
    box-shadow: 0 0.1875rem 0.375rem rgba(200, 200, 200, 0.5);
    margin:0;

     &:hover{
      color: $color-white;
      border: 2px solid #D5D5D5;
      cursor:default
    }
    &:focus{
      color: $color-white;
      border: 2px solid #D5D5D5;
      cursor:default
    }
  }
}

.custom-file-upload {
  display: flex;
  flex-direction: column;

  &__input{
   display: flex;
   width: 100%;

   &__button{
     background-color: #9E9E9E;
     padding: 0 2rem;
   }

   &__file{
     border: 1px solid #D5D5D5;
     color: #BABABA;
     font-size: $font-size;
     font-family: $font-family;
     display: flex;
     width: 100%;
     justify-content:center;
     align-items:center;
     border-top-right-radius: 0.4rem;
     border-bottom-right-radius: 0.4rem;

     span{
       font-size: 1rem;
     }
   }
   &__icon{
     cursor: pointer;
     color:#D5D5D5;
     display:flex;
     align-items: center;
     &:hover{
      color: $color-grey-dark;
    }
   }
  }

}

</style>
