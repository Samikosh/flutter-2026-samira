sealed class Countdown {
  const Countdown();
}

class CountdownUpcoming extends Countdown {
  final Duration duration;
  const CountdownUpcoming(this.duration);
}

class CountdownStarted extends Countdown {
  final Duration duration;
  const CountdownStarted(this.duration);
}

class CountdownEnded extends Countdown {
  const CountdownEnded();
}

Countdown getCountdown(DateTime when) {
  final now = DateTime.now();
  final diff = when.difference(now);

  if (diff.isNegative) {
    if (diff.inHours > -1) {
      return CountdownStarted(diff.abs());
    }
    return const CountdownEnded();
  }
  return CountdownUpcoming(diff);
}
