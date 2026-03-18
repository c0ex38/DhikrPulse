import Foundation

struct EsmaItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let arabic: String
    let meaning: String
    let targetCount: Int
    
    // Uygulama geneli statik Esmaül Hüsna listesi
    // Not: Performans ve satır tasarrufu için örnek bir liste verilmiştir.
    static let all: [EsmaItem] = [
        EsmaItem(id: 1, name: "Ya Allah", arabic: "اللَّهُ", meaning: String(localized: "esma_mean_1"), targetCount: 66),
        EsmaItem(id: 2, name: "Ya Rahman", arabic: "الرَّحْمَنُ", meaning: String(localized: "esma_mean_2"), targetCount: 298),
        EsmaItem(id: 3, name: "Ya Rahim", arabic: "الرَّحِيمُ", meaning: String(localized: "esma_mean_3"), targetCount: 258),
        EsmaItem(id: 4, name: "Ya Melik", arabic: "الْمَلِكُ", meaning: String(localized: "esma_mean_4"), targetCount: 90),
        EsmaItem(id: 5, name: "Ya Kuddüs", arabic: "الْقُدُّوسُ", meaning: String(localized: "esma_mean_5"), targetCount: 170),
        EsmaItem(id: 6, name: "Ya Selam", arabic: "السَّلَامُ", meaning: String(localized: "esma_mean_6"), targetCount: 131),
        EsmaItem(id: 7, name: "Ya Mü'min", arabic: "الْمُؤْمِنُ", meaning: String(localized: "esma_mean_7"), targetCount: 136),
        EsmaItem(id: 8, name: "Ya Müheymin", arabic: "الْمُهَيْمِنُ", meaning: String(localized: "esma_mean_8"), targetCount: 145),
        EsmaItem(id: 9, name: "Ya Aziz", arabic: "الْعَزِيزُ", meaning: String(localized: "esma_mean_9"), targetCount: 94),
        EsmaItem(id: 10, name: "Ya Cebbar", arabic: "الْجَبَّارُ", meaning: String(localized: "esma_mean_10"), targetCount: 206),
        EsmaItem(id: 11, name: "Ya Mütekebbir", arabic: "الْمُتَكَبِّرُ", meaning: String(localized: "esma_mean_11"), targetCount: 662),
        EsmaItem(id: 12, name: "Ya Halik", arabic: "الْخَالِقُ", meaning: String(localized: "esma_mean_12"), targetCount: 731),
        EsmaItem(id: 13, name: "Ya Bari", arabic: "الْبَارِئُ", meaning: String(localized: "esma_mean_13"), targetCount: 214),
        EsmaItem(id: 14, name: "Ya Musavvir", arabic: "الْمُصَوِّرُ", meaning: String(localized: "esma_mean_14"), targetCount: 336),
        EsmaItem(id: 15, name: "Ya Gaffar", arabic: "الْغَفَّارُ", meaning: String(localized: "esma_mean_15"), targetCount: 1281)
    ]
}
