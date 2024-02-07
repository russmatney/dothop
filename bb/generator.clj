(ns generator
  (:require
   ;; [short.core :as short]
   [clojure.string :as str]))

(defn parse-puzzle
  [script]
  (->> script
       str/split-lines
       (map #(str/split % #""))
       (map #(map vector (range) %))
       (map vector (range))
       ;; reduce over rows
       (reduce
         (fn [row-acc [row-idx row]]
           (reduce
             (fn [acc [col-idx elem]]
               (case elem
                 "t" (-> acc
                         (assoc :end [row-idx col-idx])
                         (update :unvisited #(conj % [row-idx col-idx])))
                 "x" (assoc acc :start [row-idx col-idx])
                 "o" (update acc :unvisited #(conj % [row-idx col-idx]))
                 "." acc))
             row-acc
             row))
         {:unvisited #{}})))

(defn find-candidate
  [{:keys [start unvisited dir]}]
  (let [op   (if (#{:right :down} dir) < >)
        row? (#{:up :down} dir)
        cand
        (->> unvisited
             (filter #((if row? op =) (first start) (first %)))
             (filter #((if row? = op) (second start) (second %)))
             (sort-by (if row? first second) op)
             first)]
    (some-> cand (vector dir))))

(def opposite {:up :down :down :up :left :right :right :left})

(defn find-candidates
  [{:keys [unvisited visited last-dir] :as opts}]
  (->> [:down :up :left :right]
       (remove #(= (opposite last-dir) %))
       (mapv #(-> opts (assoc :dir %) find-candidate))
       (filter some?)
       (reduce
         (fn [acc [cand dir]]
           (assoc acc [cand (disj unvisited cand) dir] (mapv #(conj % cand) visited)))
         {})))

(defn count-paths
  [{:keys [start unvisited end]}]
  (loop [remaining {[start unvisited nil] [[start]]} invalid [] valid []]
    (if (empty? remaining)
      {:invalid invalid
       :valid   valid
       :difficulty
       (when (seq valid)
         (/ (count invalid) (count valid)))}
      (let [{:keys [remaining invalid valid]}
            (reduce
              (fn [acc [[start unvisited last-dir] visited]]
                (let [cands (find-candidates
                              {:start     start
                               :unvisited unvisited
                               :last-dir  last-dir
                               :visited   visited})]
                  (if (seq cands)
                    (update
                      acc
                      :remaining
                      (fn [rem]
                        (reduce
                          (fn [a [k visited]]
                            (update a k into visited))
                          rem
                          cands)))
                    (update
                      acc
                      (if (and
                            (empty? unvisited)
                            (= start end)) :valid :invalid)
                      into
                      visited))))
              {:remaining {}
               :invalid   invalid
               :valid     valid}
              remaining)]
        (recur remaining invalid valid)))))

(defn matrix->string
  [matrix]
  (->> matrix
       (map #(apply str %))
       (str/join "\n")))

(defn expand-puzzle
  [{:keys [has-start? has-end?] :as puzzle}]
  (cond-> [(update puzzle :dots conj ".")
           (update puzzle :dots conj "o")]
    (not has-start?)
    (conj (-> puzzle
              (assoc :has-start? true)
              (update :dots conj "x")))
    (not has-end?)
    (conj (-> puzzle
              (assoc :has-end? true)
              (update :dots conj "t")))))

(defn generate-all-puzzles
  "nxm matrices"
  [{:keys [n m]}]
  (loop [puzzles [{:dots []}] steps-left (* n m)]
    (if (zero? steps-left)
      (->> puzzles
           (filter :has-start?)
           (filter :has-end?)
           (map :dots)
           (map #(partition m %))
           (mapv matrix->string))
      (recur
        (mapcat expand-puzzle puzzles)
        (dec steps-left)))))

(defn get-nxm-stats
  "nxm matrices"
  [opts]
  (let [puzzles        (generate-all-puzzles opts)
        stats          (->> puzzles
                            (map parse-puzzle)
                            (map count-paths))
        max-valid      (->> stats
                            (map :valid)
                            (map count)
                            (apply max))
        min-difficulty (->> stats
                            (keep :difficulty)
                            (apply min))
        max-difficulty (->> stats
                            (keep :difficulty)
                            (apply max))]
    {:most-valid     (->> stats
                          (map vector puzzles)
                          (filter #(-> %
                                       second
                                       :valid
                                       count
                                       ((fn [x] (= x max-valid)))))
                          (mapv first))
     :most-difficult (->> stats
                          (map vector puzzles)
                          (filter #(-> %
                                       second
                                       :difficulty
                                       (some->
                                         ((fn [x] (= x max-difficulty))))))
                          (mapv first))}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; generation

(defn generate-dir
  [{:keys [path decay-factor repeat-modifier]
    :or   {decay-factor    1
           repeat-modifier 0.1}}]
  (let [dirs       (remove #(= % (opposite (last path))) [:left :right :up :down])
        counts     (reduce
                     (fn [acc dir] (update acc dir (fnil inc 0)))
                     {}
                     dirs)
        gen-ratios (->> counts
                        (map (fn [[dir n]] [dir
                                            (-> decay-factor
                                                (* n)
                                                Math/exp
                                                (cond->
                                                    (= dir (last path))
                                                  (* repeat-modifier)))]))
                        (into {}))
        ratio-sum  (->> gen-ratios vals (reduce +))
        gen-probs  (->> gen-ratios
                        (map (fn [[dir r]] [(/ r ratio-sum) dir]))
                        (reduce
                          (fn [acc [prob dir]]
                            (conj acc [(+ prob (or (first (last acc)) 0)) dir]))
                          []))
        choice     (rand)]
    (->> gen-probs
         (drop-while #(> choice (first %)))
         first
         second)))

(defn generate-path
  [{:keys [len decay-factor repeat-modifier]}]
  (loop [len len path []]
    (if (zero? len)
      path
      (recur
        (dec len)
        (conj
          path
          (generate-dir
            {:path            path
             :decay-factor    decay-factor
             :repeat-modifier repeat-modifier}))))))

(defn- find-next-available-coord
  [{:keys [coord invalid-ranges higher? mover] :as opts}]
  (let [selector (if higher? second first)
        new-coord
        (->> invalid-ranges
             (filter
               (fn [[l h]]
                 (and (>= coord l)
                      (<= coord h))))
             (map selector)
             (map mover)
             first)]
    (if new-coord
      (do
        #_
        (println "tried " coord ", but it was invalid, moving on to " new-coord)
        (recur (assoc opts :coord new-coord)))
      coord)))

(defn get-mover
  [{:keys [count-chooser]} dir]
  (let [adder      (if (#{:down :right} dir) + -)
        jump-count (count-chooser (rand))]
    #(adder % jump-count)))

;; eventually take a number to move
(defn gen-move [{:keys [squares invalid-ranges] :as acc} dir]
  (let [square         (last squares)
        coord-idx      (if (#{:up :down} dir) 0 1)
        off-idx        (if (#{:up :down} dir) 1 0)
        off-coord      (get square off-idx)
        coord-key      (if (#{:up :down} dir) :row :col)
        off-key        (if (#{:up :down} dir) :col :row)
        coord          (get square coord-idx)
        mover          (get-mover acc dir)
        new-coord      (find-next-available-coord
                         {:coord          (mover coord)
                          :mover          mover
                          :invalid-ranges (get-in invalid-ranges [coord-key off-coord])
                          :higher         (#{:down :right} dir)})
        new-square     (assoc square coord-idx new-coord)
        movement-range (->> [coord new-coord] sort (into []))
        full-movement  (range
                         (first movement-range)
                         (inc (second movement-range)))]
    (-> acc
        (update :squares conj new-square)
        (update-in
          [:invalid-ranges coord-key (get square off-idx)]
          (fnil conj [])
          movement-range)
        (#(reduce
            (fn [acc coord]
              (-> acc
                  (update-in
                    [:invalid-ranges off-key coord]
                    (fnil conj [])
                    [off-coord off-coord])))
            %
            full-movement)))))

(defn path->minimal-puzzle
  [path & {:keys [count-chooser]}]
  (->> path
       (reduce
         gen-move
         {:squares [[0 0]]
          :count-chooser
          count-chooser
          :invalid-ranges
          {:row {0 [[0 0]]}
           :col {0 [[0 0]]}}})
       :squares))

(defn normalize-puzzle
  [puzzle]
  (let [row-offset
        (->> puzzle
             (map first)
             (apply min)
             (* -1))
        col-offset
        (->> puzzle
             (map second)
             (apply min)
             (* -1))]
    (mapv (fn [[r c]] [(+ r row-offset) (+ c col-offset)]) puzzle)))

(defn render-puzzle
  [puzzle]
  (let [row-count    (->> puzzle (map first) (apply max) inc)
        col-count    (->> puzzle (map second) (apply max) inc)
        empty-matrix (into [] (repeat row-count (into [] (repeat col-count "."))))]
    (matrix->string
      (reduce
        (fn [matrix coords]
          (assoc-in matrix coords "o"))
        (-> empty-matrix
            (assoc-in (first puzzle) "x")
            (assoc-in (last puzzle) "t"))
        (drop-last (rest puzzle))))))





(defn gen-puzzle
  [{:keys [jump-distribution]
    :or   {jump-distribution [1 1]}
    :as   opts}]
  (let [count-chooser
        (let [total (reduce + jump-distribution)
              options
              (->> jump-distribution
                   (map #(/ % total))
                   (reductions +)
                   (map vector (drop 1 (range))))]
          (fn [choice]
            (->> options
                 (drop-while #(> choice (second %)))
                 ffirst)))]
    (-> opts
        generate-path
        (path->minimal-puzzle
          :count-chooser count-chooser)
        normalize-puzzle
        render-puzzle)))

(defn gen-puzzle-in-diff-range
  [{:keys [diff-lo diff-hi] :as opts}]
  (->>
    (repeatedly
      #(gen-puzzle opts)
      #_#(try
           (short/call!
             (short/circuit->
               (short/timeout 1000))
             (fn [] (gen-puzzle opts)))
           (catch Exception e nil)))
    (drop-while
      #(let [diff
             (some-> %
                     parse-puzzle
                     count-paths
                     :difficulty)]
         (println diff)
         (or
           (nil? diff)
           (< diff diff-lo)
           (> diff diff-hi))))
    first))

(defn gen-puzzle-with-max-valid
  [{:keys [max-valid] :as opts}]
  (->>
    (repeatedly
      (fn [] (gen-puzzle opts))
      #_#(try
           (short/call!
             (short/circuit->
               (short/timeout 1000))
             (fn [] (gen-puzzle opts)))
           (catch Exception e nil)))
    (drop-while
      #(let [valid-count
             (some-> %
                     parse-puzzle
                     count-paths
                     :valid
                     count)]
         (or
           (nil? valid-count)
           (> valid-count max-valid))))
    first))

(defn puzzle-difficulty
  [puzzle]
  (-> puzzle
      parse-puzzle
      count-paths
      :difficulty
      float))

(defn insert-randomly
  [matrix {:keys [row-count col-count char] :as opts}]
  (let [row (rand-int row-count)
        col (rand-int col-count)]
    (if (= (get-in matrix [row col]) ".")
      (assoc-in matrix [row col] char)
      (recur matrix opts))))

(defn truly-random-puzzle
  [{:keys [row-count col-count len]}]
  (matrix->string
    (loop [matrix
           (into [] (repeat row-count (into [] (repeat col-count "."))))
           len len]
      (if (= len 2)
        (-> matrix
            (insert-randomly
              {:row-count row-count
               :col-count col-count
               :char      "x"})
            (insert-randomly
              {:row-count row-count
               :col-count col-count
               :char      "t"}))
        (recur
          (insert-randomly
            matrix
            {:row-count row-count
             :col-count col-count
             :char      "o"})
          (dec len))))))

(defn hard-edge-puzzle
  [{:keys [row-count col-count len min-per-edge]}]
  (matrix->string
    (let [top-coords   (->> (repeatedly #(rand-int col-count))
                            distinct
                            (take min-per-edge))
          bot-coords   (->> (repeatedly #(rand-int col-count))
                            distinct
                            (take min-per-edge))
          left-coords  (->> (repeatedly #(rand-int row-count))
                            distinct
                            (take min-per-edge))
          right-coords (->> (repeatedly #(rand-int row-count))
                            distinct
                            (take min-per-edge))
          seed-coords
          (->> [(mapv (fn [col] [0 col]) top-coords)
                (mapv (fn [col] [(dec row-count) col]) bot-coords)
                (mapv (fn [row] [row 0]) left-coords)
                (mapv (fn [row] [row (dec col-count)]) right-coords)]
               (mapcat identity)
               set)
          _            (println seed-coords)
          seed-matrix
          (-> (reduce
                (fn [m coords]
                  (assoc-in m coords "o"))
                (into [] (repeat row-count (into [] (repeat col-count "."))))
                seed-coords)
              (insert-randomly
                {:row-count row-count
                 :col-count col-count
                 :char      "x"})
              (insert-randomly
                {:row-count row-count
                 :col-count col-count
                 :char      "t"}))]
      (loop [matrix seed-matrix
             len    (-> len (- 2) (- (count seed-coords)))]
        (if (= len 0)
          matrix
          (recur
            (insert-randomly
              matrix
              {:row-count row-count
               :col-count col-count
               :char      "o"})
            (dec len)))))))

(defn gen-truly-random-puzzle-single-sol
  [opts]
  (->>
    (repeatedly
      #(truly-random-puzzle opts))
    (drop-while
      #(let [valid-count
             (some-> %
                     parse-puzzle
                     count-paths
                     :valid
                     count)]
         (or
           (nil? valid-count)
           (not= valid-count 1))))
    first))

(defn gen-hard-edge-puzzle-single-sol
  [opts]
  (->>
    (repeatedly
      #(hard-edge-puzzle opts))
    (drop-while
      #(let [valid-count
             (some-> %
                     parse-puzzle
                     count-paths
                     :valid
                     count)]
         (or
           (nil? valid-count)
           (not= valid-count 1))))
    first))

(comment

  (def ref-puzz
    (clojure.string/replace
      "o.o....o.oo
      o.ot...o..o
      ...........
      o.o.o.oo.oo
      ..o........
      ..o.x.o...."
      #" "
      ""))

  (def puzz-26
    (clojure.string/replace
      "..o.oo
      .oooo.
      o.oo.o
      oo.t.o
      .oooxo
      ..o.oo"
      #" "
      ""))

  (def puzz-26_6
    (clojure.string/replace
      "oooo.oo
      ooo...o
      .o..o.o
      ...x...
      oto.o..
      oo.o...
      .oo..oo"
      #" "
      ""))

  (def handmade
    (clojure.string/replace
      ".oo.oo.
      o..o.oo
      ..oxo.o
      oo.o.o.
      o.otoo.
      oo.o.o.
      oo.oo.o"
      #" "
      ""))

  (puzzle-difficulty handmade)
  (puzzle-difficulty handmade2)

  (def ref-difficulty
    (-> ref-puzz
        parse-puzzle
        count-paths
        :difficulty
        float))

  (def puzz
    (gen-puzzle-in-diff-range
      {:len               30
       :decay-factor      50
       :repeat-modifier   0.1
       :diff-lo           2000
       :diff-hi           3000
       :jump-distribution [1 1]}))

  (def puzz
    (gen-puzzle-with-max-valid
      {:len               30
       :decay-factor      50
       :repeat-modifier   0.1
       :max-valid         1
       :jump-distribution [1 1]}))

  (puzzle-difficulty puzz)
  (puzzle-difficulty puzz-26)
  (puzzle-difficulty puzz-26_6)

  (gen-truly-random-puzzle-single-sol
    {:col-count 6
     :row-count 6
     :len       23})

  (def puzz
    (gen-hard-edge-puzzle-single-sol
      {:col-count    7
       :row-count    7
       :min-per-edge 3
       :len          25}))

  (def puzz *1)


  (def stats-puzz
    (-> puzz
        parse-puzzle
        count-paths))

  (->> stats-puzz
       :difficulty
       float)

  (->> stats-puzz
       :valid
       first)

  (->> stats-puzz
       :valid
       count)

  (defn permutations [coll]
    (if (empty? coll)
      (list ())
      (for [x coll
            p (permutations (remove #{x} coll))]
        (cons x p))))

  (defn valid-path? [graph path]
    (every? #(contains? (graph (first %)) (second %)) (partition 2 1 path)))

  (defn find-hamiltonian-paths [graph]
    (let [nodes (keys graph)]
      (filter #(and (= (count %) (count nodes))
                    (valid-path? graph %))
              (permutations nodes))))

  (find-hamiltonian-paths
    {:a #{:b}
     :b #{:c}
     :c #{:d}
     :d #{}})


  )
