(ns tasks
  (:require
   [babashka.process :as p]
   [babashka.fs :as fs]
   [babashka.tasks :as bb.tasks]
   [clojure.java.io :as io]
   [clojure.string :as string]))

(require '[babashka.pods :as pods])

(defn- load-filewatcher!
  "Loads the filewatcher pod on demand and returns its `watch` fn.

  Kept lazy so unrelated tasks (e.g. `bb tasks`) don't force-load the pod.
  The pod ships a generic dynamically-linked binary that fails to exec on
  hosts without a standard dynamic loader (e.g. NixOS without nix-ld), so
  `watch` prefers `watchexec` when it is available."
  []
  (pods/load-pod 'org.babashka/filewatcher "0.0.1")
  (requiring-resolve 'pod.babashka.filewatcher/watch))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn replace-ext [p ext]
  (let [old-ext (fs/extension p)]
    (string/replace (str p) (str "." old-ext) (str "." ext))))

(defn ext-match? [p ext]
  (= (fs/extension p) ext))

(defn cwd []
  (.getCanonicalPath (io/file ".")))

(defn abs-path [p]
  (if-let [path (->> p (io/file (cwd)) (.getAbsolutePath))]
    (do
      (println "Found path:" path)
      (io/file path))
    (println "Miss for path:" p)))

(defn expand
  [path & parts]
  (let [path (apply str path parts)]
    (->
      @(p/process (str "zsh -c 'echo -n " path "'")
                  {:out :string})
      :out)))

(defn is-mac? []
  (string/includes? (expand "$OSTYPE") "darwin"))

(comment
  (is-mac?))

(defn shell-and-log
  ([x] (shell-and-log {} x))
  ([opts x]
   (println x)
   (when (seq opts) (println opts))
   (bb.tasks/shell opts x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; notify
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn notify
  ([notice]
   (cond (string? notice) (notify notice nil)

         (map? notice)
         (let [subject (some notice [:subject :notify/subject])
               body    (some notice [:body :notify/body])]
           (notify subject body notice))

         :else
         (notify "Malformed ralphie.notify/notify call"
                 "Expected string or map.")))
  ([subject body & args]
   (if (is-mac?)
     (println subject body args)
     (let [opts             (or (some-> args first) {})
           print?           (:notify/print? opts)
           replaces-process (some opts [:notify/id :replaces-process :notify/replaces-process])
           exec-strs
           (cond-> ["notify-send.py" subject]
             body (conj body)
             replaces-process
             (conj "--replaces-process" replaces-process))
           _                (when print?
                              (println subject (when body (str "\n" body))))
           proc             (p/process (conj exec-strs) {:out :string})]

       ;; we only check when --replaces-process is not passed
       ;; ... skips error messages if bad data is passed
       ;; ... also not sure when these get dealt with. is this a memory leak?
       (when-not replaces-process
         (-> proc p/check :out))
       nil))))

(comment
  (notify {:subject "subj" :body {:value "v" :label "laaaa"}})
  (notify {:subject "subj" :body "BODY"}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aseprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn aseprite-bin-path []
  (if (is-mac?)
    "/Users/russ/Library/Application Support/Steam/steamapps/common/Aseprite/Aseprite.app/Contents/MacOS/aseprite"
    "aseprite"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exporting sprite sheets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn export-pixels-sheet [path]
  (if (ext-match? path "aseprite")
    (do
      (notify "Processing aseprite file" (str path) {:notify/id (str path)})
      (let [result
            (->
              ^{:out :string}
              (p/$ ~(aseprite-bin-path) -b ~(str path)
                   --format json-array
                   --sheet
                   ~(-> path (replace-ext "png")
                        (string/replace ".png" "_sheet.png"))
                   --sheet-type horizontal
                   --list-tags
                   --list-slices
                   --list-layers)
              p/check :out)]
        (when false #_verbose? (println result))))
    (println "Skipping path without aseprite extension" path)))

(defn process-pixels-dir [dir]
  (println "Checking pixels-dir" (str dir))
  (let [files          (->> dir .list vec (map #(io/file dir %)))
        aseprite-files (->> files (filter #(ext-match? % "aseprite")))
        dirs           (->> files (filter fs/directory?))]
    (doall (map export-pixels-sheet aseprite-files))
    (doall (map process-pixels-dir dirs))))

(defn process-aseprite-files
  "Attempts to find `*.aseprite` files to process with `export-pixels-sheet`.
  Defaults to looking in an `assets/` dir."
  ([] (process-aseprite-files nil))
  ([& args]
   (let [dir (or (some-> args first) "assets")]
     (if-let [p (abs-path dir)]
       (if (.isDirectory p)
         (process-pixels-dir p)
         (export-pixels-sheet p))
       (println "Error asserting dir" dir)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All/Watch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn watch-all [& args]
  (process-aseprite-files args)
  (println "--finished (all)--"))

(defn- aseprite-change? [path]
  (and (ext-match? path "aseprite")
       (not (re-seq #"_sheet" path))))

(defn watchexec-changed-paths
  "Reconstructs the absolute paths watchexec reported via its environment-mode
  event vars. Each `WATCHEXEC_*_PATH` var holds newline-separated entries that
  share the prefix in `WATCHEXEC_COMMON_PATH`."
  []
  (let [common (or (System/getenv "WATCHEXEC_COMMON_PATH") "")]
    (->> ["WATCHEXEC_CREATED_PATH"
          "WATCHEXEC_WRITTEN_PATH"
          "WATCHEXEC_RENAMED_PATH"
          "WATCHEXEC_META_CHANGED_PATH"]
         (keep #(System/getenv %))
         (mapcat #(string/split % #"\n"))
         (remove string/blank?)
         (map #(str common %))
         distinct)))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn export-changed
  "watchexec entry point: re-exports just the `.aseprite` files that changed."
  [& _]
  (doseq [path (watchexec-changed-paths)]
    (if (aseprite-change? path)
      (do (println "Change event for" path "[bb] Processing.")
          (export-pixels-sheet path))
      (println "Change event for" path "[bb] Ignoring."))))

(defn- watch-via-watchexec []
  (println "Watching .aseprite files via watchexec…")
  (bb.tasks/shell
    "watchexec --exts aseprite --emit-events-to=environment -- bb -x tasks/export-changed"))

(defn- watch-via-pod []
  (println "Watching .aseprite files via filewatcher pod…")
  (-> (Runtime/getRuntime)
      (.addShutdownHook (Thread. #(println "\nShut down watcher."))))
  ((load-filewatcher!)
   (cwd)
   (fn [event]
     (let [path (:path event)]
       (if (aseprite-change? path)
         (do (println "Change event for" path "[bb] Processing.")
             (export-pixels-sheet path))
         (println "Change event for" path "[bb] Ignoring."))))
   {:delay-ms 100})
  @(promise))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn watch
  "Watches `.aseprite` files and re-exports sprite sheets on change.

  Uses `watchexec` when it is on PATH (the flake dev shell provides it, which
  propagates through lorri/direnv), and otherwise falls back to the babashka
  filewatcher pod."
  [& _args]
  (if (fs/which "watchexec")
    (watch-via-watchexec)
    (watch-via-pod)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Build
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def build-dir "dist")

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn export
  ([] (export nil))
  ([export-name] (export export-name nil))
  ([export-name opts]
   (let [debug?      (:debug? opts)
         export-name (or export-name "dino-linux")
         build-dir   (str "dist/" export-name)
         executable  (case export-name
                       "dino-linux" "dino.x86_64")]
     (println "export" export-name build-dir)
     (-> (p/$ mkdir -p ~build-dir) p/check)
     (shell-and-log (str "godot --headless "
                         (if debug? "--export-debug" "--export-release")
                         " " export-name " " build-dir "/" executable)))))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn build-web
  ([] (build-web nil))
  ([export-name]
   (let [export-name (or export-name "dino")
         build-dir   (str "dist/" export-name)]
     (println "build-web" export-name build-dir)
     (-> (p/$ mkdir -p ~build-dir) p/check)
     (shell-and-log (str "godot --headless --export " export-name "-web " build-dir "/index.html")))))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn zip []
  (shell-and-log (str "zip " build-dir  ".zip " build-dir "/*")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; steam box art
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; constants

(def boxart-dir "assets/boxart/")
(def boxart-base-logo "assets/boxart/base_logo.aseprite")
(def boxart-base-logo-wide "assets/boxart/base_logo_wide.aseprite")
(def boxart-base-min-borders "assets/boxart/base_logo_min_borders.aseprite")
(def boxart-base-bg-no-logo "assets/boxart/base_bg_no_logo.aseprite")
(def boxart-base-logo-no-bg "assets/boxart/base_logo_no_bg.aseprite")

;; data

(def boxart-defs
  (->>
    {
     ;; :header-capsule     {:width 460 :height 215 :base boxart-base-logo-wide}
     ;; :small-capsule      {:width 231 :height 87 :base boxart-base-logo-wide}
     ;; :main-capsule       {:width 616 :height 353}
     ;; :vertical-capsule   {:width 374 :height 448}
     ;; :page-background    {:width 1438 :height 810}
     ;; :library-capsule    {:width 600 :height 900}
     ;; :library-header     {:width 460 :height 215 :base boxart-base-logo-wide}
     ;; :library-hero       {:width 3840 :height 1240 :base boxart-base-bg-no-logo}
     ;; :library-logo       {:width 1280 :height 720 :base boxart-base-logo-no-bg}
     ;; :client-icon        {:width 16 :height 16 :skip-generate true :export-ext ".jpg"}
     ;; :community-icon     {:width 184 :height 184}
     ;; :event-cover-image  {:width 800 :height 450 :base boxart-base-logo-wide}
     ;; :event-header-image {:width 1920 :height 622 :base boxart-base-logo-wide}
     :android-app-icon        {:width 512 :height 512 :base boxart-base-min-borders}
     :android-feature-graphic {:width 1024 :height 500 :base boxart-base-logo-wide}
     ;; :apple-app-store              {:width 1024 :height 1024 :base boxart-base-min-borders}
     ;; :apple-ipad-pro               {:width 167 :height 167 :base boxart-base-min-borders}
     ;; :apple-ipad-app               {:width 76 :height 76 :base boxart-base-min-borders}
     ;; :apple-ipad-app-2x            {:width 152 :height 152 :base boxart-base-min-borders}
     ;; :apple-ipad-spotlight         {:width 40 :height 40 :base boxart-base-min-borders}
     ;; :apple-ipad-spotlight-2x      {:width 80 :height 80 :base boxart-base-min-borders}
     ;; :apple-ipad-settings          {:width 58 :height 58 :base boxart-base-min-borders}
     ;; :apple-ipad-notifications     {:width 40 :height 40 :base boxart-base-min-borders}
     ;; :apple-iphone-app-3x          {:width 180 :height 180 :base boxart-base-min-borders}
     ;; :apple-iphone-app-2x          {:width 120 :height 120 :base boxart-base-min-borders}
     ;; :apple-iphone-spotlight-3x    {:width 120 :height 120 :base boxart-base-min-borders}
     ;; :apple-iphone-spotlight-2x    {:width 80 :height 80 :base boxart-base-min-borders}
     ;; :apple-iphone-settings-3x     {:width 87 :height 87 :base boxart-base-min-borders}
     ;; :apple-iphone-settings-2x     {:width 58 :height 58 :base boxart-base-min-borders}
     ;; :apple-iphone-notification-3x {:width 60 :height 60 :base boxart-base-min-borders}
     ;; :apple-iphone-notification-2x {:width 40 :height 40 :base boxart-base-min-borders}
     }
    (map (fn [[label opts]] [label (assoc opts :label label)]))
    (into {})))

;; def -> path

(defn- boxart->path
  ([b-opts]
   (boxart->path b-opts ".aseprite"))
  ([{:keys [label]} ext]
   (str boxart-dir (name label) ext)))

;; create new file

(defn- create-resized-file [{:keys [width height base] :as opts}]
  (let [new-path  (boxart->path opts)
        base-path (or base boxart-base-logo)]

    ;; delete file if one already exists
    (when (fs/exists? new-path) (fs/delete new-path))

    ;; invoke resize_canvas.lua with options
    (println (str "Creating aseprite file: " (str new-path)))
    (let [result (-> ^{:out :string}
                     (p/$ ~(aseprite-bin-path) -b ;; 'batch' mode, don't open the UI
                          ~base-path
                          ;; pass script-params BEFORE --script arg
                          --script-param ~(str "filename=" new-path)
                          --script-param ~(str "width=" width)
                          --script-param ~(str "height=" height)
                          --script "scripts/resize_canvas.lua")
                     p/check :out)]
      (println result))))

(comment
  (name :main-capsule)
  (create-resized-file {:width 616 :height 353 :label :main-capsule}))

;; export one aseprite file

(defn- aseprite-export-boxart [b-opts]
  (let [path     (boxart->path b-opts)
        png-path (boxart->path b-opts (:export-ext b-opts ".png"))]
    (println "Exporting" path "as" png-path)
    (-> (p/$ ~(aseprite-bin-path) -b ~path --save-as ~png-path)
        p/check :out)))

;; public fns

(defn generate-all-boxart []
  (->> boxart-defs
       vals
       (remove :skip-generate)
       (map create-resized-file)
       doall))

(defn export-all-boxart []
  (->> boxart-defs
       vals
       (map aseprite-export-boxart)
       doall))

(comment
  (generate-all-boxart)
  (export-all-boxart))
