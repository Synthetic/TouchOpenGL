#!/usr/bin/python

class scanner(object):
    def __init__(self, s):
        self.s = s
        self.n = 0;
        self.ignored = set(' \n\r\t')

    def skip_ignored(self):
        if self.end:
            return
        N = self.n
        while self.s[N] in self.ignored:
            N += 1
        self.n = N

    def scan_string(self, v):
        if self.end:
            return None
        saved_n = self.n
        self.skip_ignored()
        if self.s.startswith(v, self.n):
            self.n += len(v)
            return v
        else:
            n = saved_n
            return None

    def scan_upto_string(self, v):
        if self.end:
            return ''
        self.skip_ignored()
        i = self.s.find(v, self.n)
        if i == -1:
            v = self.s[self.n : ]
            self.n = len(self.s)
            return v
        else:
            v = self.s[self.n : i]
            self.n = i
            return v

    @property
    def remaining(self):
        return self.s[self.n:]

    @property
    def end(self):
        return self.n >= len(self.s)

    @property
    def more(self):
        return self.n < len(self.s)

    @property
    def current_line(self):
        start = self.s.rfind('\n', 0, self.n)
        end = self.s.find('\n', self.n)
        return self.s[start + 1 : end]

