(ns bb-godot.tasks
  (:require
   [babashka.process :as p]
   [babashka.fs :as fs]
   [babashka.tasks :as bb.tasks]
   [clojure.java.io :as io]
   [clojure.string :as string]))

(require '[babashka.pods :as pods])
(pods/load-pod 'org.babashka/filewatcher "0.0.1")
(require '[pod.babashka.filewatcher :as fw])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn replace-ext [p ext]
  (let [old-ext (fs/extension p)]
    (string/replace (str p) old-ext ext)))

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
  (string/includes? (expand "$OSTYPE") "darwin21"))

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
   (let [opts             (or (some-> args first) {})
         print?           (:notify/print? opts)
         replaces-process (some opts [:notify/id :replaces-process :notify/replaces-process])
         exec-strs
         (if (is-mac?)
           ["osascript" "-e" (str "display notification \""
                                  (cond
                                    (string? body) body
                                    (not body)     "no body"
                                    :else          "unsupported body")
                                  "\""
                                  (when subject
                                    (str " with title \"" subject "\"")))]
           (cond->
               ["notify-send.py" subject]
             body (conj body)
             replaces-process
             (conj "--replaces-process" replaces-process)))
         _                (when print?
                            (println subject (when body (str "\n" body))))
         proc             (p/process (conj exec-strs) {:out :string})]

     ;; we only check when --replaces-process is not passed
     ;; ... skips error messages if bad data is passed
     ;; ... also not sure when these get dealt with. is this a memory leak?
     (when-not replaces-process
       (-> proc p/check :out))
     nil)))

(comment
  (notify {:subject "subj" :body {:value "v" :label "laaaa"}})
  (notify {:subject "subj" :body "BODY"}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aseprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn aseprite-bin-path []
  (if (is-mac?)
    "/Applications/Aseprite.app/Contents/MacOS/aseprite"
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

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn watch
  "Defaults to watching the current working directory."
  [& _args]
  (-> (Runtime/getRuntime)
      (.addShutdownHook (Thread. #(println "\nShut down watcher."))))
  (fw/watch (cwd) (fn [event]
                    (let [ext (-> event :path fs/extension)]
                      (when (#{"aseprite"} ext)
                        (if (re-seq #"_sheet" (:path event))
                          (println "Change event for" (:path event) "[bb] Ignoring.")
                          (do
                            (println "Change event for" (:path event) "[bb] Processing.")
                            (export-pixels-sheet (:path event)))))))
            {:delay-ms 100})
  @(promise))

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

(def boxart-base-logo "assets/boxart/base_logo.aseprite")
(def boxart-base-logo-wide "assets/boxart/base_logo_wide.aseprite")
(def boxart-base-bg-no-logo "assets/boxart/base_bg_no_logo.aseprite")
(def boxart-base-logo-no-bg "assets/boxart/base_logo_no_bg.aseprite")

(def boxart-defs
  (->>
    {:header-capsule   {:width 460 :height 215 :base boxart-base-logo-wide}
     :small-capsule    {:width 231 :height 87 :base boxart-base-logo-wide}
     :main-capsule     {:width 616 :height 353}
     :vertical-capsule {:width 374 :height 448}
     :page-background  {:width 1438 :height 810}
     :library-capsule  {:width 600 :height 900}
     :library-header   {:width 460 :height 215 :base boxart-base-logo-wide}
     :library-hero     {:width 3840 :height 1240 :base boxart-base-bg-no-logo}
     :library-logo     {:width 1280 :height 720 :base boxart-base-logo-no-bg}
     :client-icon      {:width 16 :height 16 :skip-generate true :export-ext ".jpg"}
     :community-icon   {:width 184 :height 184}}
    (map (fn [[label opts]] [label (assoc opts :label label)]))
    (into {})))

(def boxart-dir "assets/boxart/")

(defn boxart->path
  ([b-opts] (boxart->path b-opts ".aseprite"))
  ([{:keys [label]} ext]
   (str boxart-dir (name label) ext)))

(defn create-resized-file
  [{:keys [base-path overwrite verbose?]}
   {:keys [width height base] :as opts}]
  (let [new-path (boxart->path opts)
        exists?  (fs/exists? new-path)]
    (when (and exists? overwrite)
      (fs/delete new-path))
    (if (and (not overwrite) exists?)
      (println "Skipping existing new-path " new-path)
      (do
        (println (str "Creating aseprite file: " (str new-path))
                 (assoc opts :notify/id (str new-path)))

        (let [base (or base base-path)]
          (fs/copy base new-path))

        (let [result
              (->
                ^{:out :string}
                (p/$ ~(aseprite-bin-path)
                     -b
                     ~(str new-path)
                     --script-param ~(str "width=" width)
                     --script-param ~(str "height=" height)
                     --script "scripts/resize_canvas.lua"
                     )
                p/check :out)]
          (when verbose? (println result)))))))

(comment
  (name :main-capsule)
  (create-resized-file
    {:base-path boxart-base-logo
     :overwrite true :verbose? true}
    {:width 616 :height 353 :label :main-capsule}))

(defn generate-boxart-files []
  (-> (p/$ mkdir -p ~boxart-dir) p/check)
  (->> boxart-defs vals (remove #(-> % :skip-generate))
       (map (partial create-resized-file
                     {:base-path boxart-base-logo
                      :verbose?  true
                      :overwrite true}))))

(defn aseprite-export-boxart-png [b-opts]
  (println "Exporting with opts" b-opts)
  (let [path     (boxart->path b-opts)
        png-path (boxart->path b-opts (:export-ext b-opts ".png"))]
    (println "Exporting" path "as" png-path)
    (-> (p/$ ~(aseprite-bin-path) -b ~path --save-as ~png-path)
        p/check :out)))

(defn export-all-boxart []
  (->> boxart-defs vals (map aseprite-export-boxart-png) doall))


(comment
  (generate-boxart-files)
  (export-all-boxart))
