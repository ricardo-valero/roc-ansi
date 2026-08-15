module [
    Duration,
    millisecond,
    second,
]

Duration : U64

millisecond : Duration
millisecond = 1

second : Duration
second = millisecond * 1000
