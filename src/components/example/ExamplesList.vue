<template>
  <div>
    <paginated-list
      v-if="examplesList"
      :item-component="exampleItemElem"
      :list="examplesList"
      :repository="repository"
      :per-page="perPage"
      @itemSave="dispatchSave"
      @itemDeleted="onItemDeleted($event)" />

    <br>
    <div v-if="examplesList && examplesList.empty">
      <p
        v-if="textData === ''"
        class="no-examples"
        v-html="$t('webapp.trainings.no_sentences')"/>
      <p
        v-else
        v-html="$t('webapp.trainings.no_train_sentence')"/>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import PaginatedList from '@/components/shared/PaginatedList';
import ExampleItem from '@/components/example/ExampleItem';

const components = {
  PaginatedList,
};

export default {
  name: 'ExamplesList',
  components,
  props: {
    query: {
      type: Object,
      default: () => ({}),
    },
    perPage: {
      type: Number,
      default: 20,
    },
    update: {
      type: Boolean,
      default: false,
    },
    textData: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      examplesList: null,
      exampleItemElem: ExampleItem,
      dateLastTrain: '',
    };
  },
  computed: {
    ...mapGetters({
      repositoryVersion: 'getSelectedVersion',
      repository: 'getCurrentRepository',
    }),
  },
  watch: {
    query() {
      this.updateExamples(true);
    },
    update() {
      this.updateExamples(true);
    },
    repository() {
      this.updateExamples(true);
    },
  },
  mounted() {
    this.updateExamples();
  },
  methods: {
    ...mapActions([
      'searchExamples',
      'getRepositoryStatusTraining',
    ]),
    dispatchSave() {
      this.updateExamples(true);
    },
    async updateExamples(force = false) {
      await this.getRepositoryStatus();
      if (this.repositoryStatus.count !== 0) {
        if (this.repositoryStatus.results[0].status !== 2
          && this.repositoryStatus.results[0].status !== 3) {
          if (this.repositoryStatus.results[1].created_at !== undefined) {
            this.dateLastTrain = (this.repositoryStatus.results[1].created_at).replace(/[A-Za-z]/g, ' ');
          }
        } else if (this.repositoryStatus.results[0].created_at !== undefined) {
          this.dateLastTrain = (this.repositoryStatus.results[0].created_at).replace(/[A-Za-z]/g, ' ');
        }
      }

      if (!this.examplesList || force) {
        this.examplesList = await this.searchExamples({
          repositoryUuid: this.repository.uuid,
          version: this.repositoryVersion,
          query: this.query,
          limit: this.perPage,
          endCreatedAt: this.dateLastTrain,
        });
      }
    },
    async getRepositoryStatus() {
      const { data } = await this.getRepositoryStatusTraining({
        repositoryUUID: this.repository.uuid,
        repositoryVersion: this.repositoryVersion,
      });
      this.repositoryStatus = data;
    },
    onItemDeleted() {
      this.$emit('exampleDeleted');
    },
  },
};
</script>

<style lang="scss" scoped>
.no-examples {
  margin: 8px;
}
</style>
