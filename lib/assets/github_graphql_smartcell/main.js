import * as Vue from "https://cdn.jsdelivr.net/npm/vue@3.2.26/dist/vue.esm-browser.prod.js";

export function init(ctx, info) {
  ctx.importCSS("main.css");
  ctx.importCSS("https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap");

  const app = Vue.createApp({
    template: `
    <div class="app">
      <!-- Info Messages -->
      <form @change="handleFieldChange">
        <div class="container">
          <div class="row header">
            <BaseInput
              name="variable"
              label=" Assign query results to "
              type="text"
              placeholder="Assign to"
              v-model="fields.variable"
              inputClass="input input--xs input-text"
              :inline
              :required
            />
          </div>

          <div class="row">
            <BaseInput
              name="endpoint"
              label="Endpoint"
              type="text"
              placeholder="https://api.github.com/graphql"
              v-model="fields.endpoint"
              inputClass="input"
              :grow
            />
          </div>
          <div class="row">
            <BaseInput
              name="api_token"
              label="API Token"
              type="password"
              placeholder="PASTE API TOKEN"
              v-model="fields.api_token"
              inputClass="input"
              :grow
            />
          </div>
          <div class="row">
            <BaseTextArea
              name="query"
              label="Query"
              type="text"
              placeholder="{ now }"
              v-model="fields.query"
              inputClass="input"
              :grow
            />
          </div>
        </div>
      </form>
    </div>
    `,

    data() {
      return {
        fields: info.fields,
      }
    },

    methods: {
      handleFieldChange(event) {
        const { name, value } = event.target;
        ctx.pushEvent("update_field", { field: name, value });
      },
    },

    components: {
      BaseInput: {
        props: {
          label: {
            type: String,
            default: ''
          },
          inputClass: {
            type: String,
            default: 'input'
          },
          modelValue: {
            type: [String, Number],
            default: ''
          },
          inline: {
            type: Boolean,
            default: false
          },
          grow: {
            type: Boolean,
            default: false
          },
          number: {
            type: Boolean,
            default: false
          }
        },

        template: `
        <div v-bind:class="[inline ? 'inline-field' : 'field', grow ? 'grow' : '']">
          <label v-bind:class="inline ? 'inline-input-label' : 'input-label'">
            {{ label }}
          </label>
          <input
            :value="modelValue"
            @input="$emit('update:data', $event.target.value)"
            v-bind="$attrs"
            v-bind:class="[inputClass, number ? 'input-number' : '']"
          >
        </div>
        `
      },
      BaseTextArea: {
        props: {
          label: {
            type: String,
            default: ''
          },
          inputClass: {
            type: String,
            default: 'input'
          },
          modelValue: {
            type: [String, Number],
            default: ''
          },
          inline: {
            type: Boolean,
            default: false
          },
          grow: {
            type: Boolean,
            default: false
          },
          number: {
            type: Boolean,
            default: false
          }
        },

        template: `
        <div v-bind:class="[inline ? 'inline-field' : 'field', grow ? 'grow' : '']">
          <label v-bind:class="inline ? 'inline-input-label' : 'input-label'">
            {{ label }}
          </label>
          <textarea
            rows=10
            :value="modelValue"
            @input="$emit('update:data', $event.target.value)"
            v-bind="$attrs"
            v-bind:class="[inputClass, number ? 'input-number' : '']"
          >
        </div>
        `
      },
    }
  }).mount(ctx.root);

  ctx.handleEvent("update", ({ fields }) => {
    setValues(fields);
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change", { bubbles: true }));
  });

  function setValues(fields) {
    for (const field in fields) {
      app.fields[field] = fields[field];
    }
  }
}
