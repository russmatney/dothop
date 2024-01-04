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

(def box-art-defs
  {:header-capsule   {:x 460 :y 215}
   :small-capsule    {:x 231 :y 87}
   :main-capsule     {:x 616 :y 353}
   :vertical-capsule {:x 374 :y 448}
   :page-background  {:x 1438 :y 810}
   :library-capsule  {:x 600 :y 900}
   :library-hero     {:x 3840 :y 1240}
   :library-logo     {:x 1280 :y 720}
   :client-icon      {:x 16 :y 16}
   :community-icon   {:x 184 :y 184}})

(defn create-aseprite-file [{:keys [x y label]}]
  (let [dir "assets/brand/box-art/"]
    (-> (p/$ mkdir -p ~dir) p/check)
    (let [path (str dir label ".aseprite")]
      (if (fs/exists? path "aseprite")
        (println "Skipping existing path " path)
        (do
          (notify "Creating aseprite file" (str path) {:notify/id (str path)})
          (let [result
                (->
                  ^{:out :string}
                  (p/$ ~(aseprite-bin-path)
                       -b ~(str path)
                       )
                  p/check :out)]
            (when false #_verbose? (println result)))))))
  )

(defn generate-box-art-source-files []
  (println "hi")

  (->> box-art-defs
       (map (fn [[label opts]] (assoc opts :label label)))
       (take 2)
       (map create-aseprite-file))
  )

(defn export-box-art [])
